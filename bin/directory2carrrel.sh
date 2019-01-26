#!/usr/bin/env bash

# directory2carrel.sh - given a directory, initialize a study carrel, cache/harvest content, and build the carrel

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 19, 2018 - first cut


# configure
CACHE='cache';
CARREL2ZIP='./bin/carrel2zip.pl'
CARRELS='./carrels'
HOME=$READER_HOME
INITIALIZECARREL='./bin/initialize-carrel.sh'
MAKE='./bin/make.sh'
MAKENAME='./bin/make-name.sh'
PREFIX='http://cds.crc.nd.edu/reader/carrels'
SUFFIX='etc'

# validate input
if [[ -z $1 ]]; then

	echo "Usage: $0 <directory>" >&2
	exit

fi

# get the input
DIRECTORY=$1

# make sane
cd $HOME

# initialize a (random) name
NAME=$( $MAKENAME )

# create a study carrel
$INITIALIZECARREL $NAME

# copy files accordingly; this will not recurse nor copy dot files
cp $DIRECTORY/* "$CARRELS/$NAME/$CACHE"

# build the carrel; the magic happens here
$MAKE $NAME

# zip it up
$CARREL2ZIP $NAME

# done
# done
echo "$PREFIX/$NAME/$SUFFIX/$NAME.zip"
echo "$PREFIX/$NAME/$SUFFIX/$NAME.zip" | mailx -s "text mining" emorgan@nd.edu
exit