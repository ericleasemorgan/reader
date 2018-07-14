#!/usr/bin/env bash

# urls2cache.sh - give a file listing a set of urls, cache the the remove content locally

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 8, 2018 - first cut


# configure
URL2CACHE='./bin/urls2cache.pl'
CACHE='/cache';

# validate input
if [[ -z $1 || -z $2 ]]; then

	echo "Usage: $0 <file> <directory>"  >&2
	exit

fi

# get the input
FILE=$1
DIRECTORY=$2

# make sane
mkdir -p "$DIRECTORY$CACHE"

# process each line from input
while read URL; do

    # debug and do the work
    echo "$URL" >&2
    $URL2CACHE $URL "$DIRECTORY$CACHE"
    sleep 1
    
done < $FILE

# done
exit