#!/usr/bin/env bash

# cordpos2carrel.sh - given a CORD txt file name, copy the corresponding part-of-speech file

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# August 12, 2020 - first cut; there is no reason to recreate the entity files


# configure
CORDPOS=/export/reader/cord/pos
CARRELPOS=./pos

# sanity check
if [[ -z $1 ]]; then
	echo "Usage: $0 <file>" >&2
	exit
fi

# get input and initialize
FILE=$1
BASENAME=$( basename $FILE '.txt' )
CORDPOS="$CORDPOS/$BASENAME.pos"

# do the work and done
cp $CORDPOS $CARRELPOS
exit
