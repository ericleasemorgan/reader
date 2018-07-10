#!/usr/bin/env bash

# cache2txt.sh - given an input & output directory, use tika to transform documents to plain text

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 8, 2018 - first cut; at the cabin


# configure
TIKA='./bin/tika-server.sh'
PIDFILE='./tmp/tika-server.pid'
FILE2TXT='./bin/file2txt.sh'
SECONDS=20

# sanity check
if [[ -z "$1" || -z "$2" ]]; then
	echo "Usage: $0 <input directory> <output directory>" >&2
	exit
fi

# initialize
INPUT=$1
OUTPUT=$2

# fire up the tika server
$TIKA
sleep $SECONDS

# make sane
mkdir -p $OUTPUT

# find desirable file types and do the work
find $INPUT -name '*.html' -exec $FILE2TXT {} $OUTPUT \;
find $INPUT -name '*.pdf'  -exec $FILE2TXT {} $OUTPUT \;
find $INPUT -name '*.txt'  -exec $FILE2TXT {} $OUTPUT \;
find $INPUT -name '*.xml'  -exec $FILE2TXT {} $OUTPUT \;

# kill the server and done
PID=$( cat $PIDFILE )
kill $PID
exit
