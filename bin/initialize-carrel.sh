#!/usr/bin/env bash

# initialize-carrel.sh - given the name of a directory, initialize a "study carrel"

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 14, 2018 - first cut
# July 20, 2018 - added log directory
# July 26, 2018 - added home page
# May  24, 2019 - added files for indexing and searching


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
mkdir -p "./bin"
mkdir -p "./cache"
mkdir -p "./ent"
mkdir -p "./etc"
mkdir -p "./log"
mkdir -p "./pos"
mkdir -p "./tmp"
mkdir -p "./txt"
mkdir -p "./urls"
mkdir -p "./wrd"

# fill file system
cp ../../bin/classify.pl          "./bin"
cp ../../bin/cluster.py           "./bin"
cp ../../bin/index-db.pl          "./bin"
cp ../../bin/keyword2sentences.pl "./bin"
cp ../../bin/search-solr.pl       "./bin"
cp ../../bin/search-vec.py        "./bin"
cp ../../bin/topic-model.py       "./bin"
cp ../../etc/home.html            "./"
cp ../../etc/LICENSE              "./"
cp ../../etc/queries.sql          "./etc"
cp ../../etc/reader.sql           "./etc"
cp ../../etc/README               "./"
cp ../../etc/schema.xml           "./etc"
cp ../../etc/stopwords.txt        "./etc"
