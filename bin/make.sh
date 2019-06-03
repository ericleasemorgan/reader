#!/usr/bin/env bash

# make.sh - one script to rule them all

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 10, 2018 - first cut


# configure
CARRELS='/export/reader/carrels'
CACHE2TXT='/export/reader/bin/cache2txt.sh'
MAP='/export/reader/bin/map.sh'
REDUCE='/export/reader/bin/reduce.sh'
DB2REPORT='/export/reader/bin/db2report.sh'
REPORT='etc/report.txt'
CARREL2VEC='/export/reader/bin/carrel2vec.sh'
ABOUT='/export/reader/bin/about.pl'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# get input
NAME=$1

# start tika
java -jar /export/lib/tika/tika-server.jar &
PID=$!
sleep 10

# transform cache to plain text files
$CACHE2TXT $NAME

kill $PID

# extract parts-of-speech, named entities, etc
$MAP $NAME

# build the database
$REDUCE $NAME

# create semantic index
$CARREL2VEC $NAME

# output a report against the database
$DB2REPORT $NAME > "$CARRELS/$NAME/$REPORT"
cat "$CARRELS/$NAME/$REPORT"

# create about file
$ABOUT > ./about.html

# done
exit
