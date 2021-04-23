#!/usr/bin/env bash

# json2corpus.sh - given a pile o' JSON files, create a corpus of more human-readable plain text files
# usage: mkdir -p ./txt; find json -type f -not -name "P*" | sort | parallel ./bin/json2corpus.sh

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# May 15, 2020 - first cut; sometimes I scare myself


# configure
TXT='./cord/txt'
DB='./etc/cord.db'
JSON2TXT='json2txt.sh'

if [[ -z $1 ]]; then
	echo "Usage: $0 <json>" >&2
	exit
fi

# get input 
JSON=$1

# get the (pseudo) key, the sha
SHA=$( basename $JSON .json )

# build an SQL query, and find some other (pseudo) keys
QUERY=".mode tabs\nSELECT document_id, cord_uid FROM documents WHERE sha='$SHA'";
IFS=$'\t'
printf $QUERY | sqlite3 $DB | while read DOCID CORDID; do

	# build a file name (yet another key); a bit obtuse
	ITEM=$( printf "%06d" $DOCID )
	FILE="cord-$ITEM-$CORDID.txt"

	# don't do the work, if it has already been done
	if [[ -f "$TXT/$FILE" ]]; then break; fi
	
	# do the work
	$JSON2TXT $JSON > $TXT/$FILE

# fini
done
exit

