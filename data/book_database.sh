#!/bin/bash

database="$(dirname "$0")/books.csv"

case "${1:-}" in
  list)
    cat "$database"
    ;;
  add)
    title=${2:-}
    author=${3:-}
    genre=${4:-}
    status=${5:-want_to_read}
    link=${6:-}

    if [[ -z "$title" || -z "$author" ]]; then
      printf "Title and author are required.\n" >&2
      exit 1
    fi

    case "$status" in
      want_to_read|reading|read) ;;
      *)
        printf "Invalid reading status.\n" >&2
        exit 1
        ;;
    esac

    if [[ ! -s "$database" ]]; then
      printf "title,author,genre,status,rating,link\n" \
        > "$database" || exit 1
    fi

    python3 -c '
import csv
import sys

title, author, genre, status, link = sys.argv[1:]
writer = csv.writer(sys.stdout, lineterminator="\n")
writer.writerow([title, author, genre, status, "", link])
' "$title" "$author" "$genre" "$status" "$link" \
      >> "$database" || exit 1

    printf "Book saved.\n"
    ;;
  *)
    printf 'Usage: bash data/book_database.sh list | add "Title" "Author" ["Genre" "Status" "Link"]\n' >&2
    exit 1
    ;;
esac
