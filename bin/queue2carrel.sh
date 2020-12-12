#!/usr/bin/env bash

# queue2carrel.sh  - given a TSV file, initialize a carrel and submit it for processing

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# May      28, 2020 - first cut; while Gus is literally on his last legs
# June      2, 2020 - added provenance
# June      3, 2020 - added partition
# July     31, 2020 - added exit if carrel already exists; will no longer overwrite, hmmm
# November 28, 2020 - made to work with Azure; on Thanksgiving vacation in Lancaster during a pandemic


# configure
SEARCH2CARREL='search2carrel.sh'
CARRELS="$READERCORD_HOME/carrels"
CORD2CARREL='cord2carrel.sh'
#CARRELSUBMIT='carrel-submit.sh'

# sanity check
if [[ -z $1 ]]; then 
	echo "Usage: $0 <file>" >&2
	exit
fi
FILE=$1

# make sane
cd $READERCORD_HOME

# initialize
IFS=$'\t'

# read the file
cat $FILE | while read TYPE SHORTNAME DATE TIME EMAIL QUERY; do

	# debug
	echo "        file: $FILE" >&2
	echo "        type: $TYPE" >&2
	echo "  short name: $SHORTNAME" >&2
	echo "        date: $DATE"      >&2
	echo "        time: $TIME"      >&2
	echo "       email: $EMAIL"     >&2
	echo "       query: $QUERY"     >&2

	# don't to the work if it has already been done
	if [[ -d "$CARRELS/$SHORTNAME" ]]; then
		echo "       Carrel exists. Exiting." >&2
		exit
	fi
	
	# initialize the carrel with data
	$SEARCH2CARREL $SHORTNAME "$QUERY"
	
	# for reasons of provenance, copy the queue file to the carrel
	cp $FILE "$CARRELS/$SHORTNAME/provenance.tsv"
	
	# make sane and do the work
	echo "Making sane and doing the work ($CORD2CARREL)" >&2
	cd "$CARRELS/$SHORTNAME"
	$CORD2CARREL 1>standard-output.txt 2>standard-error.txt &

	# create a slurm script and submit it; do the work
	#$CARRELSUBMIT $SHORTNAME $PARTITION $EMAIL
	
# fini
done
exit
