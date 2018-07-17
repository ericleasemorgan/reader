#!/usr/bin/env bash

# url2carrel.sh - give single, initialize a study carrel, cache/harvest content, and build the carrel

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 17, 2018 - first cut


# configure
CACHE='cache';
CARREL2ZIP='./bin/carrel2zip.pl'
CARRELS='./carrels'
HOME='/afs/crc.nd.edu/user/e/emorgan/local/reader'
INITIALIZECARREL='./bin/initialize-carrel.sh'
MAKE='./bin/make.sh'
MAKENAME='./bin/make-name.sh'
TMP='./tmp'
HTML2URLS='./bin/html2urls.pl'
URL2CACHE='./bin/urls2cache.pl'

# validate input
if [[ -z $1 ]]; then

	echo "Usage: $0 <url>" >&2
	exit

fi

# get the input
URL=$1

# make sane
cd $HOME

# initialize a (random) name
NAME=$( $MAKENAME )

# create a study carrel
$INITIALIZECARREL $NAME

# get the given url and cache the content locally
wget -k -O "$TMP/$NAME" $URL

# extract the urls in the cache
$HTML2URLS "$TMP/$NAME" > "$TMP/$NAME.txt"

# process each line from cache and... cache again
while read URL; do

    # debug and do the work
    echo "$URL" >&2
    $URL2CACHE $URL "$CARRELS/$NAME/$CACHE"
    sleep 1
    
done < "$TMP/$NAME.txt"

# build the carrel; the magic happens here
$MAKE $NAME

# zip it up
$CARREL2ZIP $NAME

# done
echo $HOME/$NAME
exit