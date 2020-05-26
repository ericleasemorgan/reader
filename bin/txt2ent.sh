#!/usr/bin/env bash

# txt2ent.sh - given a file, execute txt2ent.py
# usage: mkdir -p ./ent; find ./txt -name '*.txt' | sort | parallel ./bin/txt2ent.sh

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2018 - first cut
# May  26, 2020 - adapting for Distant Reader CORD


# configure
TXT2KEYWORDS='./bin/txt2ent.py'
WRD='./ent'

# sanity check
if [[ -z $1 ]]; then
	echo "Usage: $0 <file>" >&2
	exit
fi

# get input
FILE=$1

# compute output
BASENAME=$( basename $FILE .txt )
OUTPUT="$WRD/$BASENAME.ent"

# debug 
echo $BASENAME >&2

# optionally, do the work
if [ ! -f $OUTPUT ]; then $TXT2KEYWORDS $FILE > $OUTPUT; fi




