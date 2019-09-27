#!/usr/bin/env bash

# list-keywords.sh - count & tabulate the keywords in the study carrel


TMP='./tmp'

if [[ ! $1 || ! $2 ]]; then

	echo "Usage: $0 <name> <another name>" >&2
	exit
fi

AUTHOR01=$1
AUTHOR02=$2
AUTHOR03=$3
AUTHOR04=$4


# do the work
csvstack ./bib/*.bib |  csvgrep -t -c author -r "$AUTHOR01$" |  csvcut -c id,author > "$TMP/author-01.csv"
csvstack ./bib/*.bib |  csvgrep -t -c author -r "$AUTHOR02$" |  csvcut -c id,author > "$TMP/author-02.csv"
csvstack ./bib/*.bib |  csvgrep -t -c author -r "$AUTHOR03$" |  csvcut -c id,author > "$TMP/author-03.csv"
csvstack ./bib/*.bib |  csvgrep -t -c author -r "$AUTHOR04$" |  csvcut -c id,author > "$TMP/author-04.csv"
csvstack "$TMP/author-02.csv" "$TMP/author-01.csv" "$TMP/author-03.csv" "$TMP/author-04.csv"
