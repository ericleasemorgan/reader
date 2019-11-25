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
#mkdir -p "./bin"
mkdir -p "./cache"
#mkdir -p "./cgi-bin"
mkdir -p "./css"
mkdir -p "./ent"
mkdir -p "./etc"
mkdir -p "./figures"
mkdir -p "./htm"
mkdir -p "./js"
#mkdir -p "./log"
mkdir -p "./pos"
mkdir -p "./tmp"
mkdir -p "./tsv"
mkdir -p "./txt"
mkdir -p "./urls"
#mkdir -p "./lib"
mkdir -p "./wrd"

# fill file system
#cp -r ../../etc/Lingua                  "./etc"
#cp ../../bin/about.pl                   "./bin"
#cp ../../bin/classify.pl                "./bin"
#cp ../../bin/cluster.py                 "./bin"
#cp ../../bin/concordance.pl             "./bin"
#cp ../../bin/list-items.sh              "./bin"
#cp ../../bin/make-mallet-metadata.sh    "./bin"
#cp ../../bin/make-subset.sh             "./bin"
#cp ../../bin/mallet-visualize-pivot.py  "./bin"
#cp ../../bin/mallet-visualize.py        "./bin"
#cp ../../bin/db2solr.pl                 "./bin"
#cp ../../bin/keyword2sentences.pl       "./bin"
#cp ../../bin/lines2files.pl             "./bin"
#cp ../../bin/list-questions.pl          "./bin"
#cp ../../bin/ngrams.pl                  "./bin"
#cp ../../bin/query.sh                   "./bin"
#cp ../../bin/search-solr.pl             "./bin"
#cp ../../bin/search-vec.py              "./bin"
#cp ../../bin/topic-model.py             "./bin"
#cp ../../cgi-bin/concordance.cgi        "./cgi-bin"
#cp ../../cgi-bin/search-solr.cgi        "./cgi-bin"
cp ../../css/*                          "./css"
#cp ../../etc/about.htm                  "./etc"
#cp ../../etc/home.html                  "./"
cp ../../etc/LICENSE                    "./"
cp ../../etc/queries.sql                "./etc"
cp ../../etc/reader.sql                 "./etc"
cp ../../etc/README                     "./"
#cp ../../etc/schema.xml                 "./etc"
cp ../../etc/stopwords.txt              "./etc"
#cp ../../etc/style.css                  "./etc"
#cp ../../etc/tfidf-toolbox.pl           "./etc"
cp ../../js/*                           "./js"
#cp ../../lib/*.js                       "./lib"
#cp ../../lib/*.css                      "./lib"

echo "Initializing database" >&2
$INITIALIZEDB "$CARRELS/$NAME"


