#!/usr/bin/env bash

# list-keywords.sh - count & tabulate the keywords in the study carrel


if [[ ! $1 ]]; then

	echo "Usage: $0 <integer>" >&2
	exit
fi

COUNT=$1

# do the work
csvstack ./wrd/*.wrd | csvstat -c keyword --freq --freq-count $COUNT
 
