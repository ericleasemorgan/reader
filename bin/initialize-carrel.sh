#!/usr/bin/env bash

# initialize-carrel.sh - given the name of a directory, initialize a "study carrel"

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 14, 2018 - first cut
# July 20, 2018 - added log directory
# July 26, 2018 - added home page


# configure
CARRELS='/export/reader/carrels'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# get input and make sane
NAME=$1
cd "$CARRELS/$NAME"

# create file system
mkdir -p "./adr"
mkdir -p "./bib"
mkdir -p "./cache"
mkdir -p "./ent"
mkdir -p "./etc"
mkdir -p "./pos"
mkdir -p "./txt"
mkdir -p "./urls"
mkdir -p "./wrd"
mkdir -p "./log"
mkdir -p "./tmp"

# fill file system
cp ../../etc/README        "./"
cp ../../etc/LICENSE       "./"
cp ../../etc/home.html     "./"
cp ../../etc/stopwords.txt "./etc"
cp ../../etc/queries.sql   "./etc"
cp ../../etc/reader.sql    "./etc"
