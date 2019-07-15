#!/usr/bin/env bash

# url2carrel.sh - give single url, create a study carrel

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July  17, 2018 - first cut
# April 12, 2019 - got it working on the Science Gateway cluster


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

# configure
CARRELS='/export/reader/carrels'
INITIALIZECARREL='/export/reader/bin/initialize-carrel.sh'
TMP="$CARRELS/$NAME/tmp"
HTML2URLS='/export/reader/bin/html2urls.pl'
URL2CACHE='/export/reader/bin/urls2cache.pl'
CACHE='cache';
MAKE='/export/reader/bin/make.sh'
CARREL2ZIP='/export/reader/bin/carrel2zip.pl'
PREFIX='http://cds.crc.nd.edu/reader/carrels'
SUFFIX='etc'
LOG="$CARRELS/$NAME/log"
TIMEOUT=5
DB='./etc/reader.db'

# validate input
if [[ -z $1 ]]; then

	echo "Usage: $0 <url> [<address>]" >&2
	exit

fi

# initialize log
echo "$0 $1 $2" >&2

# get the input
URL=$1

# create a study carrel
echo "Creating study carrel named $NAME" >&2
echo "" >&2
$INITIALIZECARREL $NAME

# get the given url and cache the content locally
echo "Getting URL ($URL) and saving it ($TMP/$NAME)" >&2
wget -t $TIMEOUT -k -O "$TMP/$NAME" $URL  >&2

# extract the urls in the cache
echo "Extracting URLs ($TMP/NAME) and saving ($TMP/$NAME.txt)" >&2
$HTML2URLS "$TMP/$NAME" > "$TMP/$NAME.txt"

# process each line from cache and... cache again
echo "Processing each URL in $TMP/$NAME.txt" >&2
cat "$TMP/$NAME.txt" | /export/bin/parallel --will-cite $URL2CACHE {} "$CARRELS/$NAME/$CACHE"

# process each file in the cache
for FILE in cache/* ; do

	# parse
	FILE=$( basename $FILE )
	ID=$( echo ${FILE%.*} )
	
	# output
	echo "INSERT INTO bib ( 'id' ) VALUES ( '$ID' );" >> ./tmp/bibliographics.sql
	
done

# update the bibliographic table
echo "BEGIN TRANSACTION;"     > ./tmp/update-bibliographics.sql
cat ./tmp/bibliographics.sql >> ./tmp/update-bibliographics.sql
echo "END TRANSACTION;"      >> ./tmp/update-bibliographics.sql
cat ./tmp/update-bibliographics.sql | sqlite3 $DB


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
echo "Done" >&2
exit
