#!/bin/bash

library=$(bash ./data/book_database.sh list) || exit 1

python3 -c '
import csv
import io
import sys

def normalize(text):
    return " ".join(text.split()).casefold()

def book_key(title, author):
    return (normalize(title), normalize(author))

owned = set()

for book in csv.DictReader(io.StringIO(sys.argv[1])):
    owned.add(book_key(book.get("title") or "",
                       book.get("author") or ""))

candidates = {}

for row in csv.reader(sys.stdin):
    if len(row) != 6 or not row[0].strip():
        continue

    key = book_key(row[0], row[1])

    if key in owned:
        continue

    if key in candidates:
        candidates[key]["count"] += 1
    else:
        candidates[key] = {"row": row, "count": 1}

ranked = sorted(
    candidates.values(),
    key=lambda item: item["count"],
    reverse=True
)

writer = csv.writer(sys.stdout, lineterminator="\n")
writer.writerow(["title", "author", "genre", "status", "rating", "link"])

for item in ranked[:5]:
    writer.writerow(item["row"])
' "$library"
