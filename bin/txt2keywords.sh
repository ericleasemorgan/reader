#!/usr/bin/env bash

# txt2keywords.sh - given a file, execute txt2keywords.py

# usage: find carrels/word2vec/txt -name '*.txt' -exec ./bin/txt2keywords.sh {} \;

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2018 - first cut


# configure
TXT2KEYWORDS='./bin/txt2keywords.py'
WRD='wrd'

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
mkdir -p "$ORIGINAL/../$WRD"
OUTPUT="$ORIGINAL/../$WRD/$LEAF.wrd"

# echo and do the work
echo "$LEAF  $OUTPUT" >&2

if [ -f "$OUTPUT" ]; then
	echo "$OUTPUT exist" >&2
else
	$TXT2KEYWORDS $FILE 1> $OUTPUT
fi




