#!/usr/bin/env bash

# file2txt.sh - convert a file harvested from the Web file to plain text; wrapper around tika-client.pl
# usage: find corpora/wikipedia/text-mining -name '*.html' -exec ./bin/file2txt.sh {} \;

# Eric Lease Morgan <emorgan@nd.edu>
# April 10, 2018 - first documentation; getting closer to Prague

# (c) University of Notre Dame under a GNU Public License


# configure
TIKACLIENT='./bin/tika-client.pl'

# sanity check
if [[ -z "$1" || -z "$2" ]]; then
	echo "Usage: $0 <file> <directory>" >&2
	exit
fi


# get input
FILE=$1
DIRECTORY=$2

# add error checking here

# initialize
DIRNAME=$( dirname $FILE )
BASENAME=$( basename "$FILE" )
BASENAME="${BASENAME%.*}"

# do the work
$TIKACLIENT $FILE > "$DIRECTORY/$BASENAME.xhtml"

# done
exit
