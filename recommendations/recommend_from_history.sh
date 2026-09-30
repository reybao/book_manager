#!/bin/bash

library=$(bash ./data/book_database.sh list) || exit 1

author=$(printf "%s\n" "$library" | python3 -c '
import csv
import sys

for book in csv.DictReader(sys.stdin):
    author = (book.get("author") or "").strip()
    if author:
        print(author)
        break
') || exit 1

if [[ -z "$author" ]]; then
  printf "Add a book with an author to get history recommendations.\n" >&2
  exit 0
fi

response=$(curl -fsS --max-time 30 --get \
  'https://openlibrary.org/search.json' \
  --data-urlencode "author=$author" \
  --data-urlencode 'fields=title,author_name' \
  --data-urlencode 'limit=5') || exit 1

printf "%s\n" "$response" |
  jq -r '
    .docs[] |
    [
      .title,
      ((.author_name // []) | join("; ")),
      "",
      "want_to_read",
      "",
      ""
    ] |
    @csv
  '
