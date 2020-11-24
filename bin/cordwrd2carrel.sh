#!/usr/bin/env bash

# cordwrd2carrel.sh - given a CORD txt file name, copy the corresponding keyword file

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# August 12, 2020 - first cut; there is no reason to recreate the entity files


# configure
CORDWRD="$READERCORD_HOME/cord/wrd"
CARRELWRD=./wrd

# sanity check
if [[ -z $1 ]]; then
	echo "Usage: $0 <file>" >&2
	exit
fi

# get input and initialize
FILE=$1
BASENAME=$( basename $FILE '.txt' )
CORDWRD="$CORDWRD/$BASENAME.wrd"

# do the work and done
cp $CORDWRD $CARRELWRD
exit
