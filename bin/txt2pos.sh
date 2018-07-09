#!/usr/bin/env bash

# txt2pos.sh - given a file name, run txt2pos.py
# usage: find carrels/word2vec/txt -name '*.txt' -exec ./bin/txt2pos.sh {} \;

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2018 - first cut


# configure
ID2POS='./bin/txt2pos.py'
POS='pos'

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
mkdir -p "$ORIGINAL/../$POS"
OUTPUT="$ORIGINAL/../$POS/$LEAF.pos"

# echo; debug
echo "$LEAF  $OUTPUT" >&2

# do the work
if [ -f "$OUTPUT" ]; then
	echo "$OUTPUT exist" >&2
else
	$ID2POS $FILE 1> $OUTPUT
fi




