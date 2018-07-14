#!/usr/bin/env bash

# initialize-carrel.sh - given the name of a directory, initialize a "study carrel"

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 14, 2018 - first cut


# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <directory>" >&2
	exit
fi

# create file system
mkdir -p "$1"
mkdir -p "$1/adr"
mkdir -p "$1/bib"
mkdir -p "$1/cache"
mkdir -p "$1/ent"
mkdir -p "$1/etc"
mkdir -p "$1/pos"
mkdir -p "$1/txt"
mkdir -p "$1/urls"
mkdir -p "$1/wrd"

# fill file system
cp ./etc/README        "$1"
cp ./etc/LICENSE       "$1"
cp ./etc/stopwords.txt "$1/etc"
cp ./etc/queries.sql   "$1/etc"
cp ./etc/reader.sql    "$1/etc"
