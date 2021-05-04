#!/usr/bin/env bash

# txt2ent.sh - given a file name, run txt2ent.py
# usage: find carrels/word2vec/txt -name '*.txt' -exec ./bin/txt2ent.sh {} \;
# usage: find carrels/asist/txt -name '*.txt' -exec qsub -N TXT2ENT -o ./log/txt2ent ./bin/txt2ent.sh {} \;

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2018 - first cut


# configure
ID2ENT='/export/reader/bin/txt2ent.py'
ENT='ent'

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
mkdir -p "$ORIGINAL/../$ENT"
OUTPUT="$ORIGINAL/../$ENT/$LEAF.ent"

# echo; debug
echo "$LEAF  $OUTPUT" >&2

# optionally, do the work
if [ -f "$OUTPUT" ]; then
	echo "$OUTPUT exist" >&2
else
	$ID2ENT "$FILE" 1> "$OUTPUT"
fi

