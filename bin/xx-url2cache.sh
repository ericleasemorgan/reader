#!/usr/bin/env bash

# url2cache.sh - given a (Wikipedia) URL and a directory, cache it as well as all the URLs it contains

# Eric Lease Morgan <eric_morgan@infomotions.com>
# April 3, 2018 - first cut


# configure
URL2CACHE='./bin/url2cache.pl'

# check for input
if [[ -z $1 || -z $2 ]]; then

	echo "Usage: $0 <url> <directory>\n"  >&2
	exit

fi

# get the input
URL=$1
DIRECTORY=$2
ITEM=-1

<<<<<<< HEAD
# set up environment, and cache the root url
cd $DIRECTORY
wget -k -nc -E -O $ROOT $URL

# extract the URLs; kewl and can always use improvement
URLS=( $( cat $ROOT | egrep -o 'https?://[^ ]+' | sed -e 's/https/http/g' |  sed -e 's/>.*//g' | sed -e 's/\W+$/\n/g' | sed -e 's/"//g'| sort | uniq | sed -e 's/^.*wikimediafoundation.*$//g' | sed -e 's/^.*mediawiki.*$//g' | sed -e 's/^.*wikipedia.*$//g' | sed -e 's/\n+//g' | uniq | sort -bnr ) )
=======
# cache the given directory, and capture the links it contains
let "ITEM++"
URLS=( $( $URL2CACHE $URL $DIRECTORY $ITEM ) )
>>>>>>> d8e1a8d893f90be9df5b5c50e073268e282efe57

# process each URL
for URL in "${URLS[@]}"; do
	
	# increment and do the work ignoring the result
	let "ITEM++"
	$URL2CACHE $URL $DIRECTORY $ITEM
	
done

# quit
exit