# Appunti di Basi di Dati

> 📥 **Scarica gli ultimi appunti**: [Ultima Release](https://github.com/alessandroamella/appunti-db/releases/latest)

Appunti per il corso di Basi di Dati, Laurea in Informatica, Unibo, 2025.

## Informazioni sul Corso

- [Pagina del corso](https://www.unibo.it/it/studiare/insegnamenti-competenze-trasversali-moocs/insegnamenti/insegnamento/2024/443720)
- [Materiale del professore (slide, appunti, esami)](https://drive.google.com/drive/folders/11NSPS3vsueNZxyBYRmMgVsYlbP8vKhuX)

## Scripts Utili

### Generazione Immagini UML

Lo script `generate_images.sh` genera le immagini UML utilizzate negli appunti. Richiede:

- Java
- PlantUML (scarica `plantuml.jar` da [plantuml.com](https://plantuml.com/download))
- ImageMagick (per conversione PNG)

```bash
# Posiziona plantuml.jar nella root del progetto o specifica il path in .env
PLANTUML_JAR=/path/to/plantuml.jar
```

### Fix Indentazione Minted

Lo script `fix_minted_indent.sh` corregge l'indentazione dei blocchi di codice minted in LaTeX:

```bash
./fix_minted_indent.sh input.tex > output.tex
```

## Setup e Release

Per generare una release degli appunti:

1. Installa le dipendenze:

```bash
pnpm install
```

2. Crea un file `.env` con le variabili d'ambiente come definite nel file `.env.example`.

3. Comandi disponibili:

```bash
pnpm release              # Crea una release standard
pnpm release -m "msg"     # Crea una release con messaggio personalizzato
```

## Licenza

[CC-BY-SA-4.0](LICENSE).

## By

Alessandro Amella

- [GitHub](https://github.com/alessandroamella)
