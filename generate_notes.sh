#!/bin/bash

# Versione completa per la generazione del documento finale
echo "==================================================================="
echo "= Script per generare un documento LaTeX unificato da file multipli ="
echo "==================================================================="

# Prima verifica che tutti i file esistano
echo "Verifico che tutti i file necessari siano presenti..."

FILES=(
  "01-introduzione.tex"
  "02-relazioni.tex"
  "03-algebra-relazionale.tex"
  "04-sql.tex"
  "05-sql-avanzato.tex"
  "06-db-design.tex"
  "07-modello-concettuale.tex"
  "08-modello-logico.tex"
  "09-normalizzazione.tex"
  "10-db-attivi.tex"
  "lab-01-algebra.tex"
  "lab-02-sql.tex"
  "lab-03-04-architettura-transazioni.tex"
  "lab-05-progettazione.tex"
  "lab-06-indici.tex"
  "lab-07-hash.tex"
  "preambolo_comune.tex"
)

MISSING=false
for FILE in "${FILES[@]}"; do
  if [ ! -f "$FILE" ]; then
    echo "⚠️ File mancante: $FILE"
    MISSING=true
  fi
done

if [ "$MISSING" = true ]; then
  echo "Alcuni file necessari mancano. Assicurati che tutti i file siano nella directory corrente."
  exit 1
fi

echo "✅ Tutti i file necessari sono presenti."

# 1. Crea il documento master
echo "Creando il documento master 'appunti_completi.tex'..."

cat >appunti_completi.tex <<'EOT'
\documentclass{report}

% Importa tutte le configurazioni dal preambolo comune modificato
\input{preambolo_comune_modificato}

% Hyperref configurazione globale (sovrascrive quella nel preambolo)
\hypersetup{
    colorlinks=true,
    linkcolor=white,
    filecolor=magenta,
    urlcolor=cyan,
    pdftitle={Appunti Completi di Basi di Dati},
    pdfauthor={Alessandro Amella},
    pdfpagemode=FullScreen,
}

% Titolo del documento unificato
\title{\Huge Appunti Completi di Basi di Dati\\
  \large Basati sulle dispense del Prof. Danilo Montesi}
\author{Alessandro Amella, Gemini e Claude}
\date{\today}

\begin{document}

\maketitle
\tableofcontents
\clearpage

\chapter*{Informazioni sul Documento}
\addcontentsline{toc}{chapter}{Informazioni sul Documento}

Questo documento è la versione compilata automaticamente di tutti i miei appunti di Basi di Dati per il corso di Laurea in Informatica all'Università di Bologna.

\begin{itemize}
  \item \textbf{Fonte}: Tutti gli appunti sono disponibili come file separati nella repository GitHub: 
        \url{https://github.com/alessandroamella/appunti-db}
  \item \textbf{Generazione}: Questo PDF è stato generato automaticamente utilizzando uno script che unisce tutti i singoli file .tex degli appunti.
  \item \textbf{Immagini}: Le immagini sono generate con PlantUML. Maggiori informazioni sono disponibili nel \href{https://github.com/alessandroamella/appunti-db/blob/master/README.md}{README} del progetto.
  \item \textbf{Aggiornamenti}: Per la versione più recente degli appunti, visita la pagina delle release:
        \url{https://github.com/alessandroamella/appunti-db/releases/latest}
  \item \textbf{Uso di AI}: Ho usato Gemini e Claude a manetta.
\end{itemize}

\doclicenseThis

Sentiti libero di utilizzare, condividere o contribuire a questi appunti attraverso la repository GitHub.

\clearpage

\chapter{Introduzione ai Database}
\input{01-introduzione}

\chapter{Modello Relazionale dei Dati}
\input{02-relazioni}

\chapter{Algebra Relazionale e Calcolo Relazionale}
\input{03-algebra-relazionale}

\chapter{SQL Base}
\input{04-sql}

\chapter{SQL Avanzato}
\input{05-sql-avanzato}

\chapter{Modellazione Concettuale dei Dati}
\input{06-db-design}

\chapter{Progettazione Concettuale di Basi di Dati}
\input{07-modello-concettuale}

\chapter{Progettazione Logica dei Database}
\input{08-modello-logico}

\chapter{Normalizzazione dei Database}
\input{09-normalizzazione}

\chapter{Database Attivi}
\input{10-db-attivi}

\chapter{Laboratorio 1: Algebra Relazionale}
\input{lab-01-algebra}

\chapter{Laboratorio 2: SQL}
\input{lab-02-sql}

\chapter{Laboratorio 3 e 4: Architettura e Transazioni}
\input{lab-03-04-architettura-transazioni}

\chapter{Laboratorio 5: Progettazione}
\input{lab-05-progettazione}

\chapter{Laboratorio 6: Indici e B+ Alberi}
\input{lab-06-indici}

\chapter{Laboratorio 7: Hash Table e Indici Invertiti}
\input{lab-07-hash}

\end{document}
EOT

echo "✅ appunti_completi.tex creato."

# 2. Crea preambolo_comune_modificato.tex senza la riga \documentclass
echo "Creando preambolo_comune_modificato.tex..."
sed '/\\documentclass/d' preambolo_comune.tex >preambolo_comune_modificato.tex
echo "✅ preambolo_comune_modificato.tex creato."

# 3. Compila il documento automaticamente
echo
echo "==================================================================="
echo "Compilando il documento..."
pdflatex -shell-escape appunti_completi.tex

echo "Compilando una seconda volta per l'indice..."
pdflatex -shell-escape appunti_completi.tex

echo "✅ Compilazione completata."
echo "Il documento PDF è stato generato come 'appunti_completi.pdf'"

echo "==================================================================="
echo "Processo completato con successo!"
echo "==================================================================="
