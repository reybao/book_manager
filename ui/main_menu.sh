#!/bin/bash

while true; do
  choice=$(gum choose \
    "Browse Library" \
    "Add Book" \
    "Search Library" \
    "Get Recommendations" \
    "Quit") || exit 0

  case "$choice" in
    "Get Recommendations")
      interest=$(gum input \
        --value "Science Fiction" \
        --placeholder "Your reading interest") || continue

      discovery=$(gum input \
        --value "Philosophy" \
        --placeholder "A topic to explore") || continue

      if recommendations=$(bash ./workflows/get_recommendations.sh \
        "$interest" "$discovery"); then
        printf "%s\n" "$recommendations" |
          bash ./ui/recommendations_screen.sh
      else
        printf "Unable to load recommendations.\n"
      fi

      read -r -p "Press Enter to return to the menu..."
      ;;
    "Search Library")
      bash ./workflows/manage_library.sh search
      ;;
    "Browse Library")
      bash ./workflows/manage_library.sh list
      ;;
    "Add Book")
      bash ./workflows/manage_library.sh add
      ;;
    "Quit")
      break
      ;;
    *)
      printf "You selected: %s\n" "$choice"
      read -r -p "Press Enter to return to the menu..."
      ;;
  esac
done
