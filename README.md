# Personal Book Manager

A terminal based application for managing a personal reading library and discovering new books. It uses Bash to coordinate small programs, Gum to provide an interactive terminal interface, and Open Library to retrieve online book information.

## Features

- Browse books saved in a local library
- Add books using online metadata or manual entry
- Record books as `want_to_read`, `reading`, or `read`
- Search saved books by title or author
- Generate up to five personalized recommendations
- Review book information before saving it

## Requirements

- Bash
- [Gum](https://github.com/charmbracelet/gum)
- curl
- jq
- Python 3

Internet access is required for metadata lookup and recommendations. Browsing and searching saved books work locally.

On macOS, Gum can be installed with:

```bash
brew install gum
```

## Running the Application

Open a terminal in the project directory and run:

```bash
bash app.sh
```

Use the arrow keys to move through the menu and press Enter to select an option.

## Application Architecture

The application follows this general flow:

```text
User Interface → Workflows → Components → Data → Storage
```

`app.sh` starts the application. Scripts in `ui/` display menus, input fields, and tables using Gum. Scripts in `workflows/` coordinate complete operations such as adding a book or generating recommendations. The `books/` and `recommendations/` directories contain focused components for metadata lookup, library search, candidate generation, and recommendation refinement. The `data/book_database.sh` script provides the central read and write interface for the permanent local library stored in `data/books.csv`.

Bash connects these programs with arguments, background processes, temporary files, and pipes. `curl` communicates with Open Library, `jq` processes JSON responses, and small Python helpers handle structured CSV data.

## Project Structure

```text
book-manager/
├── app.sh
├── books/
│   ├── fetch_book_metadata.sh
│   └── search_books.sh
├── data/
│   ├── book_database.sh
│   └── books.csv
├── recommendations/
│   ├── recommend_for_discovery.sh
│   ├── recommend_from_history.sh
│   ├── recommend_from_interests.sh
│   └── refine_recommendations.sh
├── ui/
│   ├── library_screen.sh
│   ├── main_menu.sh
│   └── recommendations_screen.sh
└── workflows/
    ├── get_recommendations.sh
    └── manage_library.sh
```

## Library Management

The permanent personal library is stored in `data/books.csv`. Adding a book can begin with an Open Library search. The user selects a matching result or enters the information manually, reviews the metadata, chooses a reading status, and confirms whether to save it.

Browsing and searching read from the local CSV file. These operations do not require an internet connection.

## Recommendation Workflow

The recommendation workflow launches three independent background tasks:

- **History:** searches using an author found in the saved library
- **Interests:** searches using a reading interest such as Science Fiction
- **Discovery:** searches using an exploration topic such as Philosophy

Each task retrieves candidates from Open Library and writes them to a temporary file. The workflow waits for all three tasks, interleaves their results, and sends the combined candidates through a refinement component.

Refinement excludes books already saved in the library, removes duplicate title and author pairs, ranks repeated candidates, and returns up to five books. Temporary files are removed automatically when the workflow finishes.

Open Library acts as an external book catalog. The application does not connect to an LLM while it is running.

## Personalization

I enjoy science fiction and have read *The Three-Body Problem* by Cixin Liu. Science Fiction is the default recommendation interest, while Philosophy is the default discovery topic. Both values can be changed through the interface.

The application also lets me review online metadata, enter details manually, and record whether a book is one I want to read, am currently reading, or have already read.

## Current Limitations

- Online search results can include unrelated books and should be reviewed.
- History recommendations currently use the first available author.
- Translated titles and author aliases may not be recognized as duplicates.
- The application does not prevent duplicate records when adding books.
- Existing records cannot yet be edited through the menu.
- Ratings are included in the CSV structure but are not currently collected.
- The final recommendation list does not guarantee a book from every source.

## Demo

[Watch the narrated application demo](https://youtu.be/zda538j9eqQ)

## Acknowledgments

The project architecture was adapted from the [ps02 starter repository](https://github.com/onexi/ps02). Book metadata and recommendation candidates are provided by [Open Library](https://openlibrary.org/). Codex assisted with development and explanations.

## License

This project is available under the MIT License.
