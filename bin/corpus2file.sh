#!/usr/bin/env bash

# corpus2file.sh - given a list of files on STDIN, output a data structure suitable for jslda.js (topic modeling)

# Eric Lease Morgan <emorgan@nd.edu>
# August 11, 2019 - first cut; at the cabin before Philadelphia


# configure
DATE='----'

if [[ -z $1 ]]; then
	echo "Usage: $0 <file>" >&2
	exit
fi

# get input
FILE=$1

# create a key
KEY=$( basename "$FILE" .txt )

# translate newlines, remove multiple spaces, remove leading space, escape special characters
RECORD=$( cat $FILE | tr '\n' ' ' | sed -E "s/[[:space:]]+/ /g" | sed -E "s/^ //" | sed -E 's/%/%%/g' | sed -E 's/\\/\\\\/g' )

# output
printf "$KEY\t$DATE\t$RECORD\n"

