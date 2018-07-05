#!/usr/bin/env bash

# raw2txt.sh - given two directories, use tika to transform documents to plain text

# usage: java -jar ./lib/tika.jar -t directory another-directory

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2018 - first cut


# sanity check
if [[ -z "$1" || -z "$2" ]]; then
	echo "Usage: $0 <directory> <another directory>" >&2
	exit
fi

# initialize
INPUT=$1
OUTPUT=$2

# do the work
java -jar ./lib/tika.jar -t -i $INPUT -o $OUTPUT
