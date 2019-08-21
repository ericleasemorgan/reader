#!/usr/bin/env bash

# list-questions.sh - given a study carrel, output all its questions; a front-end to list-questions.pl

# Eric Lease Morgan <emorgan@nd.edu>
# August 17, 2019 - while investigating Philadelphia as a place to "graduate"


CARRELS='/export/reader/carrels'
LISTQUESTIONS='/export/reader/bin/list-questions.pl'
TXT='./txt/*.txt'
PARALLEL='/export/bin/parallel'

if [[ -z $1 ]]; then
	echo "Usage: $0 <short-name>"  >&2
	exit
fi

# get input
CARREL=$1

# make sane
cd "$CARRELS/$CARREL"

# do the work and done
find $TXT | while read FILE; do echo $( basename $FILE .txt ); done | $PARALLEL --will-cite $LISTQUESTIONS {}
exit
