#!/usr/bin/env bash

# zip2carrel.sh - given a pre-configured zip file, create a Distant Reader Study Carrel

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# May      22, 2019 - first cut
# November 17, 2019 - hacked to accepte command line input and rename input file


# sanity check
if [[ -z $1 ]]; then
	echo "Usage: $0 <zip file>" >&2
	exit
fi	

# rename input to a "standard" name; a hack
mv "$1" ./input.zip

# set up environment
PERL_HOME='/export/perl/bin'
JAVA_HOME='/export/java/bin'
PYTHON_HOME='/export/python/bin'
WORD2VEC_HOME='/export/word2vec/bin'
PATH=$PYTHON_HOME:$WORD2VEC_HOME:$PERL_HOME:$JAVA_HOME:$PATH
export PATH

# get the name of newly created directory
NAME=$( pwd )
NAME=$( basename $NAME )
echo "Created carrel: $NAME" >&2
echo "" >&2

# configure some more
INITIALIZECARREL='/export/reader/bin/initialize-carrel.sh'
ZIP2CACHE='/export/reader/bin/zip2cache.sh'
CARRELS='/export/reader/carrels'
CACHE='cache';
TMP="$CARRELS/$NAME/tmp"
MAKE='/export/reader/bin/make.sh'
CARREL2ZIP='/export/reader/bin/carrel2zip.pl'
LOG="$CARRELS/$NAME/log"

# create a study carrel
echo "Creating study carrel named $NAME" >&2
echo "" >&2
$INITIALIZECARREL $NAME

# unzip the zip file and put the result in the cache
echo "Unzipping $ZIP" >&2
$ZIP2CACHE $NAME

# build the carrel; the magic happens here
echo "Building study carrel named $NAME" >&2
$MAKE $NAME
echo "" >&2

# zip it up
echo "Zipping study carrel" >&2
cp "$LOG/$NAME.log" "$NAME/log" 
$CARREL2ZIP $NAME
echo "" >&2

# make zip file accessible
cp "./etc/reader.zip" "./study-carrel.zip"


# done
exit