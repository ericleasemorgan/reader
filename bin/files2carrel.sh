#!/usr/bin/env bash

# files2carrel.sh - given one or more files with a specific extension, initialize a study carrel, cache/harvest content, and build the carrel

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July  19, 2018 - first cut
# July  20, 2018 - started getting to work from a remote machine and sending email
# April 20, 2019 - building off of other work; at the Culver Coffee Shop


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
CACHE='cache';
CARREL2ZIP='/export/reader/bin/carrel2zip.pl'
INITIALIZECARREL='/export/reader/bin/initialize-carrel.sh'
MAKE='/export/reader/bin/make.sh'


# create a study carrel
echo "Creating study carrel named $NAME" >&2
echo "" >&2
$INITIALIZECARREL $NAME

# fill up the cache with the given files
echo "Building cache" >&2
echo "" >&2
find ./ -name "*.ukn" -exec cp {} "$CACHE" \;

# build the carrel; the magic happens here
echo "Building study carrel named $NAME" >&2
$MAKE $NAME
echo "" >&2

# zip it up
echo "Zipping study carrel" >&2
echo "" >&2
$CARREL2ZIP $NAME

# make zip file accessible
cp "./etc/reader.zip" "./study-carrel.zip"

# done
exit
