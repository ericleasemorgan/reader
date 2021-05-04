#!/usr/bin/env bash

# make-subset.sh - given a type, directory, and value, create a subset of files


# sanity check
if [[ ! $1 || ! $2  || ! $3 ]]; then
	echo "Usage: $0 <author|date|keyword> <directory> <value>" >&2
	exit
fi

# get input
TYPE=$1
DIRECTORY=$2
VALUE=$3

# make sane
mkdir -p "$DIRECTORY"

# initialize
if [[ $TYPE == 'author' ]]; then
	DATA='./bib/*.bib'
	COLUMN='author'
elif [[ $TYPE == 'date' ]]; then
	DATA='./bib/*.bib'
	COLUMN='date'
elif [[ $TYPE == 'keyword' ]]; then
	DATA='./wrd/*.wrd' 
	COLUMN='keyword'
else
	echo "Usage: $0 <author|date|keyword> <directory> <value>" >&2
	exit
fi

# do the work; would like to use regular expressions but quoting is weird
csvstack $DATA | csvgrep -t -c $COLUMN -m "$VALUE" | csvcut -c id | tail -n +2 | while read FILE; do
	cp "./txt/$FILE.txt" "$DIRECTORY"
done

# fini
exit
