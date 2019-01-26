#!/usr/bin/env bash

# zotero2carrel.sh - given a Zotero RDF file, create a study carrel

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 16, 2018 - first cut


# configure
CACHE='cache';
CARREL2ZIP='./bin/carrel2zip.pl'
CARRELS='./carrels'
HOME=$READER_HOME
INITIALIZECARREL='./bin/initialize-carrel.sh'
MAKE='./bin/make.sh'
MAKENAME='./bin/make-name.sh'
TMP='./tmp'
URL2CACHE='./bin/urls2cache.pl'
ZOTERO2URLS='./bin/zotero2urls.pl'
URLS='zotero-urls.txt'
PREFIX='http://cds.crc.nd.edu/reader/carrels'
SUFFIX='etc'
LOG='./log'

# validate input
if [[ -z $1 ]]; then

	echo "Usage: $0 <file> [<address>]" >&2
	exit

fi

# get the input
FILE=$1

# make sane
cd $HOME

# initialize a (random) name
NAME=$( $MAKENAME )
echo "Created random name: $NAME" > "$LOG/$NAME.log"

# create a study carrel
echo "Creating study carrel named $NAME" >> "$LOG/$NAME.log"
$INITIALIZECARREL $NAME

# extract urls from rdf file
echo "Extracting URLS from Zotero file" >> "$LOG/$NAME.log"
$ZOTERO2URLS "$TMP/$FILE" > "$TMP/$URLS"

# process each line from input; harvest & cache
while read URL; do

    # debug and do the work
    echo "Caching $URL to $CARRELS/$NAME/$CACHE" >> "$LOG/$NAME.log"
    $URL2CACHE $URL "$CARRELS/$NAME/$CACHE"
    sleep 1
    
done < "$TMP/$URLS"

# build the carrel; the magic happens here
echo "Building study carrel named $NAME" >> "$LOG/$NAME.log"
$MAKE $NAME

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