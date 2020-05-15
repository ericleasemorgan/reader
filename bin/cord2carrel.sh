#!/usr/bin/env bash

# cord2carrel.sh - given the CORD data set, create "study carrel plus"

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# April  3, 2020 - first investigations
# May   15, 2020 - added JSON to txt functionality 


# enhance environment
PERL_HOME='/export/perl/bin'
JAVA_HOME='/export/java/bin'
PYTHON_HOME='/export/python/bin'
PATH=$PYTHON_HOME:$PERL_HOME:$JAVA_HOME:$PATH
export PATH

# configure
CARRELS='/export/reader/carrels'
CORPUS="./etc/reader.txt"
DB='./etc/reader.db'
REPORT='./etc/report.txt'

# require
DB2REPORT='/export/reader/bin/db2report.sh'
INITIALIZECARREL='/export/reader/bin/initialize-carrel.sh'
MAP='/export/reader/bin/map.sh'
METADATA2SQL='/export/reader/bin/metadata2sql.py'
REDUCE='/export/reader/bin/reduce.sh'
JSON2TXTPDF='/export/reader/bin/json2txt-pdf.sh'
CARREL2ZIP='/export/reader/bin/carrel2zip.pl'
MAKEPAGES='/export/reader/bin/make-pages.sh'

# get the name of newly created directory
NAME=$( pwd )
NAME=$( basename $NAME )
echo "Carrel name: $NAME" >&2

# create a study carrel
echo "Creating study carrel named $NAME" >&2
$INITIALIZECARREL $NAME

# convert raw input (JSON files) to plain text
find cache -name "*.json" | parallel $JSON2TXTPDF

# unzip the zip file and put the result in the cache
echo "Reading metadata file and updating bibliogrpahics" >&2
METADATA="$CARRELS/$NAME/metadata.csv"
$METADATA2SQL $METADATA > ./tmp/bibliographics.sql
echo "=== updating bibliographic database" >&2
echo "BEGIN TRANSACTION;"     > ./tmp/update-bibliographics.sql
cat ./tmp/bibliographics.sql >> ./tmp/update-bibliographics.sql
echo "END TRANSACTION;"      >> ./tmp/update-bibliographics.sql
cat ./tmp/update-bibliographics.sql | sqlite3 $DB

# build the carrel; the magic happens here
echo "Building study carrel named $NAME" >&2

# extract parts-of-speech, named entities, etc
$MAP $NAME

# build the database
$REDUCE $NAME

# build ./etc/reader.txt; a plain text version of the whole thing
echo "Building ./etc/reader.txt" >&2
rm -rf $CORPUS >&2
find "./txt" -name '*.txt' -exec cat {} >> "$CORPUS" \;
tr '[:upper:]' '[:lower:]' < "$CORPUS" > ./tmp/corpus.001
tr '[:digit:]' ' ' < ./tmp/corpus.001 > ./tmp/corpus.002
tr '\n' ' ' < ./tmp/corpus.002 > ./tmp/corpus.003
tr -s ' ' < ./tmp/corpus.003 > "$CORPUS"

# output a report against the database
$DB2REPORT $NAME > "$CARRELS/$NAME/$REPORT"

# create about file
$MAKEPAGES $NAME

# zip it up
echo "Zipping study carrel" >&2
rm -rf ./tmp
#cp "$LOG/$NAME.log" "$NAME/log" 
$CARREL2ZIP $NAME
echo "" >&2

# make zip file accessible
cp "./etc/reader.zip" "./study-carrel.zip"

# done
exit
