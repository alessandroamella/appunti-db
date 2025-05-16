#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");
const { execSync } = require("node:child_process");
const { Octokit } = require("@octokit/rest");
const dotenv = require("dotenv-safe");
const tmp = require("tmp");
const { format } = require("date-fns");

// Load environment variables from .env file
dotenv.config();

// Configuration from environment variables
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const REPO_OWNER = process.env.REPO_OWNER || "alessandroamella";
const REPO_NAME = process.env.REPO_NAME || path.basename(process.cwd());
const PDF_PATTERN = process.env.PDF_PATTERN || "*.pdf";
const RELEASE_PREFIX = process.env.RELEASE_PREFIX || "appunti";

// Parse command line arguments
function parseArgs() {
  const args = process.argv.slice(2);
  const result = { command: args[0], message: "" };

  for (let i = 1; i < args.length; i++) {
    if (args[i] === "-m" && i + 1 < args.length) {
      result.message = args[i + 1];
      i++; // Skip the next argument as it's the message content
    }
  }

  return result;
}

// Validate required environment variables
if (!GITHUB_TOKEN) {
  console.error("Error: GITHUB_TOKEN is required in your .env file");
  process.exit(1);
}

// Initialize GitHub API client
const octokit = new Octokit({
  auth: GITHUB_TOKEN
});

/**
 * Find PDF files in the repository and sort them numerically
 */
function findPDFFiles() {
  try {
    // Use find command to get all PDF files
    const result = execSync(`find . -name "${PDF_PATTERN}" | sort -V`).toString().trim();
    const files = result.split("\n").filter(file => file);

    if (files.length === 0) {
      console.log("No PDF files found in the repository.");
      process.exit(0);
    }

    return files;
  } catch (error) {
    console.error("Error finding PDF files:", error.message);
    process.exit(1);
  }
}

/**
 * Combine PDF files into a single document
 */
async function combinePDFs(pdfFiles) {
  const formattedDate = format(new Date(), "yyyy-MM-dd_HH-mm-ss");
  const outputFile = `${RELEASE_PREFIX}_${formattedDate}.pdf`;

  // Create temp directory for the operation
  const tmpobj = tmp.dirSync({ unsafeCleanup: true });
  const tempOutputPath = path.join(tmpobj.name, outputFile);

  try {
    console.log("Combining PDFs into a single file...");

    // Use pdftk to combine PDFs
    const pdftkCommand = `pdftk ${pdfFiles.join(" ")} cat output "${tempOutputPath}"`;
    execSync(pdftkCommand, { stdio: "inherit" });

    if (!fs.existsSync(tempOutputPath)) {
      throw new Error("Failed to create combined PDF file");
    }

    console.log(`Combined PDF created: ${outputFile}`);
    return {
      filePath: tempOutputPath,
      fileName: outputFile,
      cleanup: () => tmpobj.removeCallback()
    };
  } catch (error) {
    tmpobj.removeCallback();
    console.error("Error combining PDFs:", error.message);
    process.exit(1);
  }
}

/**
 * Create a GitHub release with the combined PDF
 */
async function createGitHubRelease(pdfInfo, customMessage = "") {
  const { filePath, fileName } = pdfInfo;
  const timestamp = Math.floor(Date.now() / 1000);
  const releaseTag = `release-${timestamp}`;
  const formattedDate = format(new Date(), "yyyy-MM-dd HH:mm:ss");
  const releaseName = `${
    RELEASE_PREFIX.charAt(0).toUpperCase() + RELEASE_PREFIX.slice(1)
  } ${formattedDate}`;

  try {
    console.log("Creating GitHub release...");

    // Generate release body with PDF file names in Italian
    const pdfFiles = findPDFFiles();
    const fileList = pdfFiles.map(file => `- ${path.basename(file)}`).join("\n");
    let releaseBody = `Appunti aggiornati al ${formattedDate}.`;

    // Add custom message if provided
    if (customMessage) {
      releaseBody += `\n\n${customMessage}`;
    }

    releaseBody += `\n\nFile inclusi in questa pubblicazione:\n${fileList}`;

    // Create the release
    const release = await octokit.repos.createRelease({
      owner: REPO_OWNER,
      repo: REPO_NAME,
      tag_name: releaseTag,
      name: releaseName,
      body: releaseBody,
      draft: false,
      prerelease: false
    });

    console.log(`GitHub release created: ${releaseName}`);

    // Upload the asset
    const fileData = fs.readFileSync(filePath);
    await octokit.repos.uploadReleaseAsset({
      owner: REPO_OWNER,
      repo: REPO_NAME,
      release_id: release.data.id,
      name: fileName,
      data: fileData
    });

    console.log(`PDF file uploaded to release: ${fileName}`);
    console.log(`Release URL: ${release.data.html_url}`);

    // Clean up
    pdfInfo.cleanup();
  } catch (error) {
    pdfInfo.cleanup();
    console.error("Error creating GitHub release:", error.message);
    if (error.response) {
      console.error("API response:", error.response.data);
    }
    process.exit(1);
  }
}

/**
 * Setup Git hook for automatic releases
 */
function setupGitHook() {
  try {
    console.log("Setting up Git hook for automatic releases...");

    // Create hooks directory if it doesn't exist
    const hooksDir = path.join(process.cwd(), ".git", "hooks");
    if (!fs.existsSync(hooksDir)) {
      fs.mkdirSync(hooksDir, { recursive: true });
    }

    // Create post-commit hook
    const hookPath = path.join(hooksDir, "post-commit");
    const scriptPath = path.join(process.cwd(), "github-auto-release.js");

    fs.writeFileSync(
      hookPath,
      `#!/bin/sh
# Post-commit hook to create a GitHub release
node "${scriptPath}" release
`
    );

    // Make the hook executable
    fs.chmodSync(hookPath, "755");

    console.log("Git hook setup complete.");
    console.log("A new release will be created automatically after each commit.");
  } catch (error) {
    console.error("Error setting up Git hook:", error.message);
    process.exit(1);
  }
}

/**
 * Main function
 */
async function main() {
  const args = parseArgs();
  const command = args.command;

  switch (command) {
    case "setup":
      setupGitHook();
      break;

    case "release": {
      const pdfFiles = findPDFFiles();
      const pdfInfo = await combinePDFs(pdfFiles);
      await createGitHubRelease(pdfInfo, args.message);
      break;
    }

    default:
      console.log("GitHub Auto-Release Script (Node.js version)");
      console.log("----------------------------------------");
      console.log("This script automates creating GitHub releases with combined PDFs.");
      console.log("");
      console.log("Usage:");
      console.log(
        "  node github-auto-release.js setup                 - Set up the automatic release system"
      );
      console.log(
        "  node github-auto-release.js release               - Manually trigger a release"
      );
      console.log(
        '  node github-auto-release.js release -m "message" - Trigger a release with a custom message'
      );
      console.log("");
      console.log("Make sure to create a .env file with your GitHub token.");
  }
}

main().catch(error => {
  console.error("Unexpected error:", error);
  process.exit(1);
});
