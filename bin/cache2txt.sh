#!/usr/bin/env bash

# cache2txt.sh - given an input directory, use tika to transform documents to plain text

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 8, 2018 - first cut; at the cabin


# configure
TIKA='./bin/tika-server.sh'
PIDFILE='./tmp/tika-server.pid'
FILE2TXT='./bin/file2txt.sh'
SECONDS=10
CACHE='/cache'
TXT='/txt'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <directory>" >&2
	exit
fi

# initialize
CARREL=$1
INPUT="$CARREL$CACHE"
OUTPUT="$CARREL$TXT"

# fire up the tika server
$TIKA
sleep $SECONDS

# make sane
mkdir -p $OUTPUT

# find desirable file types and do the work
find $INPUT -name '*.html' | parallel $FILE2TXT {} $OUTPUT
find $INPUT -name '*.pdf'  | parallel $FILE2TXT {} $OUTPUT
find $INPUT -name '*.txt'  | parallel $FILE2TXT {} $OUTPUT
find $INPUT -name '*.xml'  | parallel $FILE2TXT {} $OUTPUT

# kill the server and done
PID=$( cat $PIDFILE )
kill $PID
exit
