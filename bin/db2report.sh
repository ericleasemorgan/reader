#!/usr/bin/env bash

# db2report.sh - given a "study carrel", output a canned SQL reqport

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 10, 2018 - first cut


# configure
QUERIES='./etc/queries.sql'
DB='/etc/reader.db'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <directory>" >&2
	exit
fi

# initialize
CARREL=$1

# do the work
cat $QUERIES | sqlite3 "$CARREL$DB"

