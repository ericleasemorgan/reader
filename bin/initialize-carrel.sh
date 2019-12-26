#!/usr/bin/env bash

# initialize-carrel.sh - given the name of a directory, initialize a "study carrel"

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July      14, 2018 - first cut
# July      20, 2018 - added log directory
# July      26, 2018 - added home page
# May       24, 2019 - added files for indexing and searching
# September 29, 2019 - added some file for study carrel investigation
# November  24, 2019 - trimming
# December  26, 2019 - added MANIFEST.htm


# configure
CARRELS='/export/reader/carrels'
INITIALIZEDB='/export/reader/bin/initialize-database.sh'

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
mkdir -p "./css"
mkdir -p "./ent"
mkdir -p "./etc"
mkdir -p "./figures"
mkdir -p "./htm"
mkdir -p "./js"
mkdir -p "./pos"
mkdir -p "./tmp"
mkdir -p "./tsv"
mkdir -p "./txt"
mkdir -p "./urls"
mkdir -p "./wrd"

# fill file system
cp ../../css/*             "./css"
cp ../../etc/LICENSE       "./"
cp ../../etc/MANIFEST.htm  "./"
cp ../../etc/queries.sql   "./etc"
cp ../../etc/reader.sql    "./etc"
cp ../../etc/README        "./"
cp ../../etc/stopwords.txt "./etc"
cp ../../js/*              "./js"

echo "Initializing database" >&2
$INITIALIZEDB "$CARRELS/$NAME"


