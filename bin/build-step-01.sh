#!/usr/bin/env bash

# build-step-01.sh - one script to create the CORD database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March    16, 2020 - first cut
# March    20, 2020 - added caching
# May      14, 2020 - added summary report, and removed conversation to plain text
# June      3, 2020 - added with keyword and entities data, but they really won't work unless there was pre-processing
# November 22, 2020 - updated with feature extraction; working in a pandemic in Lancaster


# configure
SOURCE='/ocean/projects/cis210016p/shared/etc/reader-cord.cfg'

# initialize and make sane
source $SOURCE
cd $READERCORD_HOME

echo "Cache CORD data set" >&2
./bin/cache.sh

echo "Extracting metadata" >&2
./bin/metadata2sql-cord.py

echo "Initializing database" >&2
./bin/db-initialize.sh

echo "Filling documents table" >&2
./bin/sql2db.sh

echo "Filling authors table" >&2
cat ./etc/authors2author.sql | sqlite3 ./etc/cord.db

echo "Filling sources table" >&2
cat ./etc/sources2source.sql | sqlite3 ./etc/cord.db

echo "Filling URLs table" >&2
cat ./etc/urls2url.sql | sqlite3 ./etc/cord.db

echo "Filling shas table" >&2
cat ./etc/shas2sha.sql | sqlite3 ./etc/cord.db

echo "Transforming JSON into plain text" >&2
mkdir -p ./cord/txt
find cord/json -type f -not -name "P*" | sort | parallel --will-cite json2corpus.sh

echo "Extracting named entities from plain text" >&2
mkdir -p ./cord/ent
find ./cord/txt -name "*.txt" | parallel ./bin/txt2ent-cord.py

echo "Extracting keywords from plain text" >&2
mkdir -p ./cord/wrd
find ./cord/txt -name "*.txt" | parallel ./bin/txt2keywords-cord.py

echo "Transforming named entity files into SQL" >&2
mkdir -p ./cord/sql-ent
find ./cord/ent -type f | parallel ./bin/ent2sql-cord.pl 2> ./log/ent2sql.log

echo "Transforming keyword files into SQL" >&2
mkdir -p ./cord/sql-wrd
find ./cord/wrd -type f | parallel ./bin/wrd2sql-cord.pl 2> ./log/wrd2sql.log

echo "Reducing named entities to database" >&2
./bin/reduce-ent-cord.sh

echo "Reducing keywords to database" >&2
./bin/reduce-wrd-cord.sh

echo "Summarizing" >&2
./bin/summarize.sh > ./report.txt

echo "Done building CORD database" >&2
exit
