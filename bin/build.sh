#!/usr/bin/env bash

# build.sh - given an input directory and an output directory, do everything

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 27, 2018 - first cut


# sanity check
if [[ -z "$1" || -z "$2" ]]; then
	echo "Usage: $0 <directory> <another directory>" >&2
	exit
fi

# initialize
INPUT=$1
OUTPUT=$2

./bin/raw2txt.sh $INPUT $OUTPUT
find $OUTPUT -name '*.txt' -exec ./bin/txt2adr.sh {} \;
find $OUTPUT -name '*.txt' -exec ./bin/txt2bib.sh {} \;
find $OUTPUT -name '*.txt' -exec ./bin/txt2ent.sh {} \;
find $OUTPUT -name '*.txt' -exec ./bin/txt2pos.sh {} \;
find $OUTPUT -name '*.txt' -exec ./bin/txt2keywords.sh {} \;
find $OUTPUT -name '*.txt' -exec ./bin/txt2urls.sh {} \;

