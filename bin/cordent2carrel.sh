#!/usr/bin/env bash

# cordent2carrel.sh - given a CORD txt file name, copy the corresponding entity file

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# August 12, 2020 - first cut; there is no reason to recreate the entity files


# configure
CORDENT="$READERCORD_HOME/cord/ent"
CARRELENT=./ent

# sanity check
if [[ -z $1 ]]; then
	echo "Usage: $0 <file>" >&2
	exit
fi

# get input and initialize
FILE=$1
BASENAME=$( basename $FILE '.txt' )
CORDENT="$CORDENT/$BASENAME.ent"

# do the work and done
cp $CORDENT $CARRELENT
exit
