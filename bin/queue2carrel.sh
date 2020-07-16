#!/usr/bin/env bash

# queue2carrel.sh  - given a TSV file, initialize a carrel and submit it for processing

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# May 28, 2020 - first cut; while Gus is literally on his last legs
# June 2, 2020 - added provenance
# June 3, 2020 - added partition


# configure
SEARCH2CARREL='./bin/search2carrel.sh'
CARRELS='/export/reader/carrels'
CARRELSUBMIT='./bin/carrel-submit.sh'
PARTITION='big-cloud'

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
	echo "        file: $FILE" >&2
	echo "  short name: $SHORTNAME" >&2
	echo "        date: $DATE"      >&2
	echo "        time: $TIME"      >&2
	echo "       email: $EMAIL"     >&2
	echo "       query: $QUERY"     >&2
	
	# initialize the carrel with data
	$SEARCH2CARREL $SHORTNAME "$QUERY"
	
	# for reasons of provenance, copy the queue file to the carrel
	cp $FILE "$CARRELS/$SHORTNAME/provenance.tsv"
	
	# create a slurm script and submit it; do the work
	$CARRELSUBMIT $SHORTNAME $PARTITION $EMAIL
	
# fini
done
exit
