#!/usr/bin/env bash

# urls2carrel.sh - given a list of URLs in a plain text file, create a Distant Reader Study Carrel

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July  8, 2018 - first cut
# July 14, 2018 - more investigation
# July 16, 2018 - made things more module


# configure input
FILE=./input-file.txt

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
URL2CACHE='/export/reader/bin/urls2cache.pl'
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

# process each line from cache and... cache again
echo "Processing each URL in $TMP/$NAME.txt" >&2
cat "./$FILE" | /export/bin/parallel $URL2CACHE {} "$CACHE"

# process each line from input; harvest & cache
#while read URL; do
#
#    # debug and do the work
#    echo "Caching $URL to $CACHE" >&2
#   $URL2CACHE $URL "$CACHE"
#    sleep 1
#    
#done < "./$FILE"
#echo "" >&2

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