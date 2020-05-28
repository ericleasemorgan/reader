#!/usr/bin/env bash

# queue2carrel.sh  - given an item in the queue, initialize a carrel and submit it for processing

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# May 28, 202 - first cut; while Gus is literally on his last legs


# configure
SEARCH2CARREL='./bin/search2carrel.sh'

# sanity check
if [[ -z $1 ]]; then 
	echo "Usage: $0 <file>" >&2
	exit
fi

# get input
FILE=$1

# initialize
IFS=$'\t'

# read the file
cat $FILE | while read SHORTNAME DATE TIME EMAIL QUERY; do

	# debug
	echo "  short name: $SHORTNAME" >&2
	echo "        date: $DATE"      >&2
	echo "        time: $TIME"      >&2
	echo "       email: $EMAIL"     >&2
	echo "       query: $QUERY"     >&2
	
	# do the work
	$SEARCH2CARREL $SHORTNAME "$QUERY"
		
# fini
done
exit
