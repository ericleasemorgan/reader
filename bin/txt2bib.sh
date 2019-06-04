#!/usr/bin/env bash

# txt2ent.sh - given a file name, run txt2ent.py

# usage: find carrels/word2vec/txt -name '*.txt' -exec ./bin/txt2bib.sh {} \;

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2018 - first cut

# configure
TXT2BIB='/export/reader/bin/txt2bib.py'
BIB='bib'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <file>" >&2
	exit
fi

# get input
FILE=$1


# compute output
ORIGINAL=$( dirname "${FILE}" )
LEAF=$( basename "$FILE" .txt )
mkdir -p "$ORIGINAL/../$BIB"
OUTPUT="$ORIGINAL/../$BIB/$LEAF.bib"

# echo and do the work
echo "$LEAF  $OUTPUT" >&2

if [ -f "$OUTPUT" ]; then
	echo "$OUTPUT exist" >&2
else
	$TXT2BIB "$FILE" 1> "$OUTPUT"
fi




