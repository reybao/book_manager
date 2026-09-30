# Personal Book Manager

A terminal book manager built for PS02 using Bash, Gum, Open Library,
jq, and small Python helpers.

## Requirements

- Bash
- Gum
- curl
- jq
- Python 3

Internet access is needed for metadata lookup and recommendations.
Browsing and searching saved books work locally. If metadata lookup
fails, book details can be entered manually.

## Run

From the project directory:

```bash
bash app.sh
```

Use the arrow keys and Enter to select menu items.

- **Browse Library:** view saved books and reading statuses.
- **Add Book:** search for metadata, select a matching book or enter
  details manually, choose a reading status, and confirm saving.
- **Search Library:** find saved records containing a keyword.
- **Get Recommendations:** enter an interest and an exploration topic
  to generate up to five recommendations.
- **Quit:** exit the application.

## Architecture

The application follows UI → Workflows → Components → Data → Storage.
`app.sh` starts the menu. The `ui/` scripts handle menus and tables,
while `workflows/` coordinates library operations and recommendation
tasks. The `books/` scripts search saved records and retrieve metadata.
Three independent scripts in `recommendations/` generate candidates.
Only `data/book_database.sh` directly accesses `data/books.csv`.
Bash coordinates the programs, curl retrieves online data, jq processes
JSON, and Python helpers handle CSV and recommendation refinement.

## Parallel Recommendation Workflow

The workflow launches three background tasks using `&`, records their
process IDs with `$!`, displays progress dots, and checks completion
with `wait`.

- **History:** queries works by the first nonempty author in the library.
- **Interests:** queries a topic such as Science Fiction.
- **Discovery:** queries a user-selected exploration topic such as Philosophy.

Each task writes to its own temporary file. The workflow interleaves
their candidates and pipes them into the refinement script. Refinement
excludes saved title-author pairs, removes duplicates, ranks candidates
by occurrence count, and returns up to five books. Ties retain input
order. Temporary files are removed when the workflow exits.

## Personalization

I enjoy science fiction and have read The Three-Body Problem by Cixin
Liu. Science Fiction is my default recommendation interest, and
Philosophy is my default exploration topic. Both can be changed in the
interface. The English terminal UI lets me record books as want to
read, reading, or read, and review metadata before saving.

## Current Limitations

- Search results can include unrelated books; users must check matches.
- Recommendations use catalog queries, not an LLM.
- History recommendations currently use only the first available author.
- Duplicate matching does not resolve translated titles or author aliases.
- Adding a book does not prevent duplicate records.
- Existing records cannot yet be edited through the menu.
- Ratings are reserved in the CSV schema but are not collected.
- The final shortlist does not guarantee a book from every source.

## Demo

Narrated demo video: pending. A video link will be added before submission.

## Acknowledgments

Based on the course starter repository: https://github.com/onexi/ps02
Book metadata and recommendation candidates come from Open Library.
Codex assisted with development and explanations.
