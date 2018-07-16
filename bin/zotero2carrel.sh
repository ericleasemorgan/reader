#!/usr/bin/env bash

# zotero2carrel.sh - given a Zotero RDF file name, create a study carrel

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 16, 2018 - first cut


# configure
CACHE='cache';
CARREL2ZIP='./bin/carrel2zip.pl'
CARRELS='./carrels'
HOME='/afs/crc.nd.edu/user/e/emorgan/local/reader'
INITIALIZECARREL='./bin/initialize-carrel.sh'
MAKE='./bin/make.sh'
MAKENAME='./bin/make-name.sh'
TMP='./tmp'
URL2CACHE='./bin/urls2cache.pl'
ZOTERO2URLS='./bin/zotero2urls.pl'
URLS='zotero-urls.txt'

# validate input
if [[ -z $1 ]]; then

	echo "Usage: $0 <file>" >&2
	exit

fi

# get the input
FILE=$1

# make sane
cd $HOME

# initialize a (random) name
NAME=$( $MAKENAME )

# create a study carrel
$INITIALIZECARREL $NAME

# extract urls from rdf file
$ZOTERO2URLS $FILE > "$TMP/$URLS"

# process each line from input; harvest & cache
while read URL; do

    # debug and do the work
    echo "$URL" >&2
    $URL2CACHE $URL "$CARRELS/$NAME/$CACHE"
    sleep 1
    
done < "$TMP/$URLS"

# build the carrel; the magic happens here
$MAKE $NAME

# zip it up
$CARREL2ZIP $NAME

# done
echo $HOME/$NAME
exit