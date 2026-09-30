#!/bin/bash

interest=${1:-}

if [[ -z "$interest" ]]; then
  printf "Please enter an interest.\n" >&2
  exit 1
fi

response=$(curl -fsS --max-time 30 --get \
  'https://openlibrary.org/search.json' \
  --data-urlencode "q=subject:\"$interest\"" \
  --data-urlencode 'fields=title,author_name' \
  --data-urlencode 'limit=5') || exit 1

printf "%s\n" "$response" |
  jq -r --arg genre "$interest" '
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
