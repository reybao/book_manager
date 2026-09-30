#!/bin/bash

title=${1:-}

if [[ -z "$title" ]]; then
  printf "Please enter a book title.\n" >&2
  exit 1
fi

response=$(curl -fsS --max-time 30 --get \
  'https://openlibrary.org/search.json' \
  --data-urlencode "title=$title" \
  --data-urlencode 'fields=key,title,author_name' \
  --data-urlencode 'limit=10') || exit 1

printf "%s\n" "$response" |
  jq -e '
    if (.docs | length) == 0 then
      error("No matching book found.")
    else
      [
        .docs[] |
        {
          title: .title,
          author: ((.author_name // []) | join("; ")),
          genre: "",
          link: (
            "https://openlibrary.org/works/" +
            (.key | split("/") | last)
          )
        }
      ]
    end
  '
