#!/usr/bin/env bash

# file2carrel.sh - given a file, initialize a study carrel, cache/harvest content, and build the carrel

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 19, 2018 - first cut
# July 20, 2018 - started getting to work from a remote machine and sending email

#SBATCH -N 1
#SBATCH --exclusive
#SBATCH -J file2c
#SBATCH -o /export/reader/log/file2carrel-%A.log

# configure
HOME=$READER_HOME
MAKENAME='./bin/make-name.sh'
INITIALIZECARREL='./bin/initialize-carrel.sh'
TMP='tmp'
CARRELS='./carrels'
CACHE='cache';
MAKE='./bin/make.sh'
CARREL2ZIP='./bin/carrel2zip.pl'
PREFIX='http://cds.crc.nd.edu/reader/carrels'
LOG='./log'

# validate input
if [[ -z $1 ]]; then

	echo "Usage: $0 <file> [<address>]" >&2
	exit

fi

# initialize log
echo "$0 $1 $2" >&2

# get the input
FILE=$1

# make sane
cd $HOME

# initialize a (random) name
NAME=$( $MAKENAME )
echo "Created random name: $NAME" > "$LOG/$NAME.log"

# create a study carrel
echo "Creating study carrel named $NAME" >> "$LOG/$NAME.log"
$INITIALIZECARREL $NAME >> "$LOG/$NAME.log"

# copy the file; this will not recurse nor copy dot files
echo "Copying $TMP/$FILE to $CARRELS/$NAME/$CACHE" >> "$LOG/$NAME.log"
cp "$TMP/$FILE" "$CARRELS/$NAME/$CACHE"

# build the carrel; the magic happens here
echo "Building study carrel named $NAME" >> "$LOG/$NAME.log"
$MAKE $NAME >> "$LOG/$NAME.log"

# zip it up
echo "Zipping study carrel" >> "$LOG/$NAME.log"
cp "$LOG/$NAME.log" "$CARRELS/$NAME/log" 
$CARREL2ZIP $NAME

# notify completion
if [[ $2 ]]; then
	ADDRESS=$2
	echo "$PREFIX/$NAME/" | mailx -s "distant reader results" $ADDRESS
else
	echo "$HOME/$CARRELS/$NAME/"
fi

# done
exit