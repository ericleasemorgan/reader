#!/usr/bin/env bash

# db2report.sh - given a "study carrel", output a canned SQL reqport

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 10, 2018 - first cut


# configure
CARRELS="$READERCORD_HOME/carrels"
QUERIES="$READERCORD_HOME/etc/queries.sql"
DB='etc/reader.db'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# initialize
NAME=$1

# do the work
cat $QUERIES | sqlite3 "$CARRELS/$NAME/$DB"

