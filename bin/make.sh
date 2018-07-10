#!/usr/bin/env bash

# make.sh - one script to rule them all

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 10, 2018 - first cut; at the cabin


# configure
CACHE2TXT='./bin/cache2txt.sh'
MAP='./bin/map.sh'
REDUCE='./bin/reduce.sh'
DB2REPORT='./bin/db2report.sh'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <directory>" >&2
	exit
fi

# initialize
CARREL=$1

$CACHE2TXT $CARREL
$MAP $CARREL
$REDUCE $CARREL
$DB2REPORT $CARREL