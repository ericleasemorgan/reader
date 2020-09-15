#!/usr/bin/env bash

# map.sh - given an directory (of .txt files), map various types of information

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June    27, 2018 - first cut
# July    10, 2018 - started using parallel, and removed files2txt processing
# July    12, 2018 - migrating to the cluster
# February 3, 2020 - tweaked a lot to accomodate large files
# June    22, 2020 - processing txt files, not json files; needs to be tidied
# August  13, 2020 - using pre-processed files


# configure
TXT='txt';
CACHE='cache'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# initialize
NAME=$1
INPUT="$TXT"

# extract addresses, urls, and keywords
find "$INPUT" -name '*.txt' | parallel /export/reader/bin/txt2adr.sh {}  &
find "$INPUT" -name '*.txt' | parallel /export/reader/bin/txt2urls.sh {} &
find "$INPUT" -name '*.txt' | parallel /export/reader/bin/file2bib.sh {} & 
wait

# copy previously created entity, part-of-speech and keyword files
find "$INPUT" -name '*.txt' | parallel /export/reader/bin/cordent2carrel.sh &
find "$INPUT" -name '*.txt' | parallel /export/reader/bin/cordpos2carrel.sh &
find "$INPUT" -name '*.txt' | parallel /export/reader/bin/cordwrd2carrel.sh &
wait

# done
echo "Que is empty; done" >&2
exit
