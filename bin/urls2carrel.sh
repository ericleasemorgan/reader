#!/usr/bin/env bash

# urls2carrel.sh - give a file listing a set of urls, initialize a study carrel, cache/harvest content, and build the carrel

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July  8, 2018 - first cut
# July 14, 2018 - more investigation
# July 16, 2018 - made things more module


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

# process each line from input; harvest & cache
while read URL; do

    # debug and do the work
    echo "$URL" >&2
    $URL2CACHE $URL "$CARRELS/$NAME/$CACHE"
    sleep 1
    
done < "$TMP/$FILE"

# build the carrel; the magic happens here
$MAKE $NAME

# zip it up
$CARREL2ZIP $NAME

# done
echo $HOME/$NAME
exit