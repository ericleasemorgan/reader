#!/usr/bin/env bash

# make.sh - one script to rule them all

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 10, 2018 - first cut


# configure
HOME='/usr/local/reader'
CARRELS='./carrels'
CACHE2TXT='./bin/cache2txt.sh'
MAP='./bin/map.sh'
REDUCE='./bin/reduce.sh'
DB2REPORT='./bin/db2report.sh'
REPORT='etc/report.txt'
CARREL2VEC='./bin/carrel2vec.sh'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# get input
NAME=$1

# make sane
cd $HOME

# transform cache to plain text files
$CACHE2TXT $NAME

# extract parts-of-speech, named entities, etc
$MAP $NAME

# build the database
$REDUCE $NAME

# create semantic index
$CARREL2VEC $NAME

# output a report against the database
$DB2REPORT $NAME > "$CARRELS/$NAME/$REPORT"
cat "$CARRELS/$NAME/$REPORT"

# done
exit
