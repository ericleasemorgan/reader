#!/usr/bin/env bash

# initialize-db.sh - given the name of a directory, initialize a distant reader database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2018 - first cut


# configure
HOME='/Users/emorgan/Desktop/reader'
ETC='etc'
DATABASE="reader.db"
SCHEMA='./etc/reader.sql'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <directory>" >&2
	exit
fi

# set up environment
cd $HOME
DIRECTORY=$1

# initialize
mkdir -p "$DIRECTORY/$ETC"
rm -rf "$DIRECTORY/$ETC/$DATABASE"
cat "$SCHEMA" | sqlite3 "$DIRECTORY/$ETC/$DATABASE"

