#!/usr/bin/env bash

# list-questions.sh - given a study carrel, output all its questions; a front-end to list-questions.pl

# Eric Lease Morgan <emorgan@nd.edu>
# August 17, 2019 - while investigating Philadelphia as a place to "graduate"


CARRELS="$READERCORD_HOME/carrels"
LISTQUESTIONS='list-questions.pl'
TXT='./txt'

if [[ -z $1 ]]; then
	echo "Usage: $0 <short-name>"  >&2
	exit
fi

# get input
CARREL=$1

# make sane
cd "$CARRELS/$CARREL"

# do the work and done
find $TXT -type f | while read FILE; do echo $( basename "$FILE" .txt ); done | parallel $LISTQUESTIONS
exit
