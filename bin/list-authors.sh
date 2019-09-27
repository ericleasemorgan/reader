#!/usr/bin/env bash

# list-authors.sh - count & tabulate the authors in the study carrel


if [[ ! $1 ]]; then

	echo "Usage: $0 <integer>" >&2
	exit
fi

COUNT=$1

# do the work
csvstack ./bib/*.bib | csvstat -t -c author --freq --freq-count $COUNT
 
