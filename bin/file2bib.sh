#!/usr/bin/env bash

# file2bib.sh - given a file name, extract bibliographics; a front-end to file2bib.py
# usage: find ./ -type f | parallel ./file2bib.sh {}

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2018 - first cut

echo "=== file2bib.sh ===" >&2

# configure
FILE2BIB='/export/reader/bin/file2bib.py'
BIB='bib'

# set up environment
export PYTHONIOENCODING=utf8

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <file>" >&2
	exit
fi

# get input
FILE=$1

# compute output
LEAF=$( basename "$FILE" )
LEAF="${LEAF%.*}"
OUTPUT="$BIB/$LEAF.bib"

# echo and do the work
$FILE2BIB "$FILE" > "$OUTPUT"





