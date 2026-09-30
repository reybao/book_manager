#!/bin/bash

topic=${1:-}

if [[ -z "$topic" ]]; then
  printf "Please enter a discovery topic.\n" >&2
  exit 1
fi

response=$(curl -fsS --max-time 30 --get \
  'https://openlibrary.org/search.json' \
  --data-urlencode "q=subject:\"$topic\"" \
  --data-urlencode 'fields=title,author_name' \
  --data-urlencode 'limit=5') || exit 1

printf "%s\n" "$response" |
  jq -r --arg genre "$topic" '
    .docs[] |
    [
      .title,
      ((.author_name // []) | join("; ")),
      $genre,
      "want_to_read",
      "",
      ""
    ] |
    @csv
  '

