#!/usr/bin/env bash

# initialize-database.sh - given the name of a directory, initialize a distant reader database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2018 - first cut


# configure
ETC='etc'
DATABASE="reader.db"
SCHEMA='/export/reader/etc/reader.sql'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <directory>" >&2
	exit
fi

# set up environment
DIRECTORY=$1

# initialize
mkdir -p "$DIRECTORY/$ETC"
rm -rf "$DIRECTORY/$ETC/$DATABASE"
cat "$SCHEMA" | sqlite3 "$DIRECTORY/$ETC/$DATABASE"

