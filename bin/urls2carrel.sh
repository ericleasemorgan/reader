#!/usr/bin/env bash

# urls2carrel.sh - given a list of URLs in a plain text file, create a Distant Reader Study Carrel

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July  8, 2018 - first cut
# July 14, 2018 - more investigation
# July 16, 2018 - made things more module


# configure
HOME='/afs/crc.nd.edu/user/e/emorgan/local/reader'
MAKENAME='./bin/make-name.sh'
INITIALIZECARREL='./bin/initialize-carrel.sh'
URL2CACHE='./bin/urls2cache.pl'
CARRELS='./carrels'
CACHE='cache';
TMP='./tmp'
MAKE='./bin/make.sh'
CARREL2ZIP='./bin/carrel2zip.pl'
PREFIX='http://cds.crc.nd.edu/reader/carrels'
LOG='./log'

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
echo "Created random name: $NAME" > "$LOG/$NAME.log"

# create a study carrel
echo "Creating study carrel named $NAME" >> "$LOG/$NAME.log"
$INITIALIZECARREL $NAME

# process each line from input; harvest & cache
while read URL; do

    # debug and do the work
    echo "Caching $URL to $CARRELS/$NAME/$CACHE" >> "$LOG/$NAME.log"
    $URL2CACHE $URL "$CARRELS/$NAME/$CACHE"
    sleep 1
    
done < "$TMP/$FILE"

# build the carrel; the magic happens here
echo "Building study carrel named $NAME" >> "$LOG/$NAME.log"
$MAKE $NAME

# zip it up
echo "Zipping study carrel" >> "$LOG/$NAME.log"
cp "$LOG/$NAME.log" "$CARRELS/$NAME/log" 
$CARREL2ZIP $NAME

# done
echo "$PREFIX/$NAME/" | mailx -s "text mining" emorgan@nd.edu
exit