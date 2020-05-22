#!/usr/bin/env bash

# txt2keywords.sh - given a file, execute txt2keywords.py
# usage: find ./txt -name '*.txt' | sort | parallel ./bin/txt2keywords.sh

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2018 - first cut
# May  20, 2020 - adapting for Distant Reader CORD


# configure
TXT2KEYWORDS='./bin/txt2keywords.py'
WRD='./wrd'

# sanity check
if [[ -z $1 ]]; then
	echo "Usage: $0 <file>" >&2
	exit
fi

# get input
FILE=$1

# compute output
BASENAME=$( basename $FILE .txt )
OUTPUT="$WRD/$BASENAME.wrd"

# debug 
echo $BASENAME >&2

# optionally, do the work
if [ ! -f $OUTPUT ]; then $TXT2KEYWORDS $FILE > $OUTPUT; fi




