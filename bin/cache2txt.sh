#!/usr/bin/env bash

# cache2txt.sh - given an input directory, use tika to transform documents to plain text

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 8, 2018 - first cut; at the cabin


# configure
CARRELS='./carrels'
HOME=$READER_HOME
#TIKA='./bin/tika-server.sh'
#PIDFILE='./tmp/tika-server.pid'
FILE2TXT='./bin/file2txt.sh'
#SECONDS=10
CACHE='cache'
TXT='txt'
#PARALLEL='/usr/bin/parallel'
JOBS=40

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# initialize
NAME=$1
INPUT="$CARRELS/$NAME/$CACHE"
OUTPUT="$CARRELS/$NAME/$TXT"

# fire up the tika server
#$TIKA
#sleep $SECONDS

# make sane
mkdir -p $OUTPUT

# find desirable file types and do the work
find $INPUT -name '*.html' | parallel --jobs $JOBS $FILE2TXT {} $OUTPUT
find $INPUT -name '*.pdf'  | parallel --jobs $JOBS $FILE2TXT {} $OUTPUT
find $INPUT -name '*.txt'  | parallel --jobs $JOBS $FILE2TXT {} $OUTPUT
find $INPUT -name '*.xml'  | parallel --jobs $JOBS $FILE2TXT {} $OUTPUT

# kill the server and done
#PID=$( cat $PIDFILE )
#kill $PID
#rm $PIDFILE
exit
