#!/bin/bash

case "${1:-}" in
  search)
    term=$(gum input --placeholder "Search title or author") || exit 0

    if [[ -n "$term" ]]; then
      bash ./books/search_books.sh "$term" |
        bash ./ui/library_screen.sh
    else
      printf "Please enter a search term.\n"
    fi

    read -r -p "Press Enter to return to the menu..."
    ;;

  list)
    bash ./data/book_database.sh list |
      bash ./ui/library_screen.sh

    read -r -p "Press Enter to return to the menu..."
    ;;

  add)
    title=$(gum input --placeholder "Book title") || exit 0

    if [[ -z "$title" ]]; then
      printf "A book title is required.\n"
      read -r -p "Press Enter to return to the menu..."
      exit 0
    fi

    author=""
    genre=""
    link=""

    printf "Looking up book information...\n"

    if matches=$(bash ./books/fetch_book_metadata.sh "$title"); then
      options=$(printf "%s\n" "$matches" | jq -r '
        to_entries[] |
        "\(.key + 1). \(.value.title) — \(.value.author)" |
        gsub("[\r\n\t]"; " ")
      ')

      selection=$(printf "%s\n%s\n" \
        "$options" "0. Enter manually" |
        gum choose --header "Choose the correct book, or enter manually") \
        || exit 0

      number=${selection%%.*}

      if [[ "$number" != "0" ]]; then
        metadata=$(printf "%s\n" "$matches" |
          jq --argjson index "$((number - 1))" '.[$index]')

        title=$(printf "%s\n" "$metadata" | jq -r '.title')
        author=$(printf "%s\n" "$metadata" | jq -r '.author')
        genre=$(printf "%s\n" "$metadata" | jq -r '.genre')
        link=$(printf "%s\n" "$metadata" | jq -r '.link')
      fi
    else
      printf "Lookup unavailable. Please enter the details manually.\n"
    fi

    title=$(gum input --header "Title" \
      --value "$title") || exit 0
    author=$(gum input --header "Author" \
      --value "$author") || exit 0
    genre=$(gum input --header "Genre (optional)" \
      --value "$genre") || exit 0
    link=$(gum input --header "Book link (optional)" \
      --value "$link") || exit 0

    status_label=$(gum choose --header "Reading status" \
      "Want to read" "Reading" "Read") || exit 0

    case "$status_label" in
      "Want to read") status="want_to_read" ;;
      "Reading") status="reading" ;;
      "Read") status="read" ;;
    esac

    printf "\nTitle: %s\nAuthor: %s\nGenre: %s\nStatus: %s\nLink: %s\n" \
      "$title" "$author" "$genre" "$status_label" "$link"

    if gum confirm "Save this book?"; then
      bash ./data/book_database.sh add \
        "$title" "$author" "$genre" "$status" "$link"
    else
      printf "Book not saved.\n"
    fi

    read -r -p "Press Enter to return to the menu..."
    ;;

  *)
    printf "Unknown library action.\n" >&2
    exit 1
    ;;
esac
