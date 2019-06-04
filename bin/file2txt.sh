#!/usr/bin/env bash

# file2txt.sh - given a file, output plain text; a front-end to file2txt.py

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# February 2, 2019 - first documentation; written a while ago; "Happy birthday, Mary!"


# configure
FILE2TXT='/export/reader/bin/file2txt.py'

# sanity check
if [[ -z "$1" || -z "$2" ]]; then
	echo "Usage: $0 <file> <directory>" >&2
	exit
fi

# get input
FILE=$1
DIRECTORY=$2

# initialize
BASENAME=$( basename "$FILE" )
BASENAME=${BASENAME%.*}
OUTPUT="$DIRECTORY/$BASENAME.txt"

echo "  FILE: $FILE" >&2
echo "OUTPUT: $OUTPUT" >&2

# do the work and done
$FILE2TXT "$FILE" > "$OUTPUT"
exit
