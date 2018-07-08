#!/usr/bin/env bash

# url2cache.sh - given a (Wikipedia) URL and a directory, cache it as well as all the URLs it contains

# Eric Lease Morgan <eric_morgan@infomotions.com>
# April 3, 2018 - first cut


# configure
URL2CACHE='./bin/url2cache.pl'

if [[ -z $1 || -z $2 ]]; then

	echo "Usage: $0 <url> <directory>\n"  >&2
	exit

fi
# get the input
URL=$1
DIRECTORY=$2
ITEM=-1

# cache the given directory, and capture the links it contains
let "ITEM++"
URLS=( $( $URL2CACHE $URL $DIRECTORY $ITEM ) )

# process each URL
for URL in "${URLS[@]}"; do
	
	# increment and do the work ignoring the result
	let "ITEM++"
	$URL2CACHE $URL $DIRECTORY $ITEM
	
done

# quit
exit