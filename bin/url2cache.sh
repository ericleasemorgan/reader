#!/usr/bin/env bash

# url2cache.sh - given a (Wikipedia) URL and a directory, cache it as well as all the URLs it contains

# Eric Lease Morgan <eric_morgan@infomotions.com>
# April 3, 2018 - first cut


# configure
ROOT='root.html'

if [[ -z $1 || -z $2 ]]; then

	echo "Usage: $0 <url> <directory>\n"  >&2
	exit

fi
# get the input
URL=$1
DIRECTORY=$2

# INSERT SANITY CHECK HERE

# set up environment, and cache the root url
cd $DIRECTORY
wget -k -nc -E -O $ROOT $URL

# extract the URLs; kewl and can always use improvement
URLS=( $( cat $ROOT | egrep -o 'https?://[^ ]+' | sed -e 's/https/http/g' |  sed -e 's/>.*//g' | sed -e 's/\W+$/\n/g' | sed -e 's/"//g'| sort | uniq | sed -e 's/^.*wikimediafoundation.*$//g' | sed -e 's/^.*mediawiki.*$//g' | sed -e 's/^.*wikipedia.*$//g' | sed -e 's/\n+//g' | uniq | sort -bnr ) )

# process each URL
C=0
for URL in "${URLS[@]}"; do
	
	# create a kewl file name based on domain
	let "C++"
	DOMAIN=$( echo $URL | sed -e 's/^http:\/\///g' | sed -e 's/\/.*$//g' | sed -e 's/\./-/g' )
	N=$( printf "%04d" $C )
	NAME="$DOMAIN-$N.htm"

	# do the work
	wget -O $NAME -k -T 5 -t 2 -E $URL

	# try to get the mime-type of the newly saved file, and initialize
	MIME=$( file --mime-type -b $NAME )
	BASE=$( basename "$NAME" .htm )
	
	# rename cached file, based on mime-type
	if   [ $MIME = 'text/html' ];                then mv $NAME "$BASE.html"
	elif [ $MIME = "inode/x-empty" ];            then rm $NAME
	elif [ $MIME = "application/octet-stream" ]; then mv $NAME "$BASE.html"
	elif [ $MIME = "application/pdf" ];          then mv $NAME "$BASE.pdf"
	elif [ $MIME = "text/xml" ];                 then mv $NAME "$BASE.xml"
    else echo "Unknown mime-type ($MIME). Call Eric"
	fi
	
done

# quit
exit