#!/bin/bash

term=${1:-}

if [[ -z "$term" ]]; then
  printf "Please enter a search term.\n" >&2
  exit 1
fi

bash ./data/book_database.sh list | {
  IFS= read -r header
  printf "%s\n" "$header"
  grep -iF -- "$term"
}
