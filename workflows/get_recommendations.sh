#!/bin/bash

set -o pipefail

interest=${1:-Science Fiction}
discovery=${2:-Philosophy}

temp_dir=$(mktemp -d) || exit 1
trap 'rm -rf "$temp_dir"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

printf "Starting recommendation searches...\n" >&2

bash ./recommendations/recommend_from_history.sh \
  > "$temp_dir/history.csv" &
history_pid=$!

(
  sleep 1
  bash ./recommendations/recommend_from_interests.sh "$interest"
) > "$temp_dir/interests.csv" &
interests_pid=$!

(
  sleep 2
  bash ./recommendations/recommend_for_discovery.sh "$discovery"
) > "$temp_dir/discovery.csv" &
discovery_pid=$!

while kill -0 "$history_pid" 2>/dev/null ||
      kill -0 "$interests_pid" 2>/dev/null ||
      kill -0 "$discovery_pid" 2>/dev/null; do
  printf "." >&2
  sleep 1
done

printf "\n" >&2

failed=0
wait "$history_pid" || failed=1
wait "$interests_pid" || failed=1
wait "$discovery_pid" || failed=1

if [[ "$failed" -ne 0 ]]; then
  printf "A recommendation search failed. Please try again.\n" >&2
  exit 1
fi

printf "Searches complete. Refining results...\n" >&2

python3 -c '
import csv
import sys
from itertools import zip_longest

groups = []

for path in sys.argv[1:]:
    with open(path, newline="", encoding="utf-8") as file:
        groups.append(list(csv.reader(file)))

writer = csv.writer(sys.stdout, lineterminator="\n")

for batch in zip_longest(*groups):
    for book in batch:
        if book is not None:
            writer.writerow(book)
' "$temp_dir/history.csv" \
  "$temp_dir/interests.csv" \
  "$temp_dir/discovery.csv" |
  bash ./recommendations/refine_recommendations.sh
