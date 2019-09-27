#!/usr/bin/env bash

# subset-keywords.sh - given a keyword and a directory, create a subset of documents

# sanity check
if [[ ! $1 || ! $2 ]]; then
	echo "Usage: $0 <author> <directory>" >&2
	exit
fi

# get input
AUTHOR=$1
DIRECTORY=$2

# initialize
mkdir -p "$DIRECTORY"

# do the work
csvstack ./bib/*.bib | \
csvgrep -t -c author -r "^$AUTHOR$" | \
csvcut -c id |  tail -n +2 | \
while read FILE; do

	cp "./txt/$FILE.txt" "$DIRECTORY"
	
done

# fini
exit
