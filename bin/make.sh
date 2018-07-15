#!/usr/bin/env bash

# make.sh - one script to rule them all

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 10, 2018 - first cut


# configure
HOME='/afs/crc.nd.edu/user/e/emorgan/local/reader'
CACHE2TXT='./bin/cache2txt.sh'
MAP='./bin/map.sh'
REDUCE='./bin/reduce.sh'
DB2REPORT='./bin/db2report.sh'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# get input
CARREL=$1

# make sane
cd $HOME

# transform cache to plain text files
$CACHE2TXT $CARREL

# extract parts-of-speech, named entities, etc
$MAP $CARREL

# build the database
$REDUCE $CARREL

# output a report against the database
$DB2REPORT $CARREL

# done
exit
