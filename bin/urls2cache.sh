#!/usr/bin/env bash

# urls2cache.sh - give a file listing a set of urls, cache the the remove content locally

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 8, 2018 - first cut


# configure
URL2CACHE='./bin/urls2cache.pl'

# validate input
if [[ -z $1 ]]; then

	echo "Usage: $0 <file>"  >&2
	exit

fi

# get the input
FILE=$1

# process each line from input
while read URL; do

    # debug and do the work
    echo "$URL" >&2
    $URL2CACHE $URL
    
done < $FILE

# done
exit