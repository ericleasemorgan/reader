#!/usr/bin/env bash

# list-items.sh - count & tabulate given metadata items


# sanity check
if [[ ! $1 || ! $2 ]]; then
	echo "Usage: $0 <author|date|keyword> <integer>" >&2
	exit
fi

# get input
TYPE=$1
COUNT=$2

# initialize
if [[ $TYPE == 'author' ]]; then
	DATA='./bib/*.bib'
	COLUMN='author'
elif [[ $TYPE == 'date' ]]; then
	DATA='./bib/*.bib'
	COLUMN='date'
elif [[ $TYPE == 'keyword' ]]; then
	DATA='./wrd/*.wrd'
	COLUMN='keyword'
else
	echo "Usage: $0 <author|date|keyword> <integer>" >&2
	exit
fi

# do the work
csvstack $DATA | csvstat -t -c $COLUMN --freq --freq-count $COUNT
 
