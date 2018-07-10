#!/usr/bin/env bash

# map.sh - given an directory (of .txt files), map various types of information

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 27, 2018 - first cut
# July 10, 2018 - started using parallel, and removed files2txt processing


# configure
TXT='/txt';

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <directory>" >&2
	exit
fi

# initialize
CARREL=$1
INPUT="$CARREL$TXT"

# do the work
find $INPUT -name '*.txt' | parallel ./bin/txt2adr.sh {}
find $INPUT -name '*.txt' | parallel ./bin/txt2bib.sh {}
find $INPUT -name '*.txt' | parallel ./bin/txt2ent.sh {}
find $INPUT -name '*.txt' | parallel ./bin/txt2pos.sh {}
find $INPUT -name '*.txt' | parallel ./bin/txt2keywords.sh {}
find $INPUT -name '*.txt' | parallel ./bin/txt2urls.sh {}

