#!/usr/bin/env bash

# url2carrel.sh - give single url, create a study carrel

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 17, 2018 - first cut


# configure
HOME=$READER_HOME
MAKENAME='./bin/make-name.sh'
INITIALIZECARREL='./bin/initialize-carrel.sh'
TMP='./tmp'
HTML2URLS='./bin/html2urls.pl'
URL2CACHE='./bin/urls2cache.pl'
CACHE='cache';
CARRELS='./carrels'
MAKE='./bin/make.sh'
CARREL2ZIP='./bin/carrel2zip.pl'
PREFIX='http://cds.crc.nd.edu/reader/carrels'
SUFFIX='etc'
LOG='./log'
TIMEOUT=5

# validate input
if [[ -z $1 ]]; then

	echo "Usage: $0 <url> [<address>]" >&2
	exit

fi

# initialize log
echo "$0 $1 $2" >&2

# get the input
URL=$1

# make sane
cd $HOME

# initialize a (random) name
NAME=$( $MAKENAME )
echo "Created random name: $NAME" > "$LOG/$NAME.log"

# create a study carrel
echo "Creating study carrel named $NAME" >> "$LOG/$NAME.log"
$INITIALIZECARREL $NAME

# get the given url and cache the content locally
echo "Getting URL ($URL) and saving it ($TMP/$NAME)" >> "$LOG/$NAME.log"
wget -t $TIMEOUT -k -O "$TMP/$NAME" $URL >> "$LOG/$NAME.log"

# extract the urls in the cache
echo "Extracting URLs ($TMP/NAME) and saving ($TMP/$NAME.txt)" >> "$LOG/$NAME.log"
$HTML2URLS "$TMP/$NAME" > "$TMP/$NAME.txt"

# process each line from cache and... cache again
echo "Processing each URL in $TMP/$NAME.txt" >> "$LOG/$NAME.log"
while read URL; do

    # debug and do the work
    echo "Caching $URL to $CARRELS/$NAME/$CACHE" >> "$LOG/$NAME.log"
    $URL2CACHE $URL "$CARRELS/$NAME/$CACHE"
    sleep 1
    
done < "$TMP/$NAME.txt"

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

