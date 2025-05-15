#!/bin/bash

# Usage: ./fix_minted_indent.sh input.tex > output.tex

awk '
BEGIN { in_minted = 0 }

/\\begin{minted}/ {
    in_minted = 1
    print
    next
}

/\\end{minted}/ {
    in_minted = 0
    first_indent = ""
    print
    next
}

in_minted == 1 {
    if (first_indent == "") {
        match($0, /^[ \t]*/)
        first_indent = substr($0, RSTART, RLENGTH)
    }
    sub("^" first_indent, "")
    print
    next
}

{
    print
}
' "$1"
