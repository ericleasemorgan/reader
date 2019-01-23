#!/usr/bin/env bash

# initialize-carrel.sh - given the name of a directory, initialize a "study carrel"

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 14, 2018 - first cut
# July 20, 2018 - added log directory
# July 26, 2018 - added home page


# configure
HOME='/usr/local/reader'
CARRELS='./carrels'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# get input
NAME=$1

# make sane
cd $HOME

# create file system
mkdir -p "$CARRELS/$NAME"
mkdir -p "$CARRELS/$NAME/adr"
mkdir -p "$CARRELS/$NAME/bib"
mkdir -p "$CARRELS/$NAME/cache"
mkdir -p "$CARRELS/$NAME/ent"
mkdir -p "$CARRELS/$NAME/etc"
mkdir -p "$CARRELS/$NAME/pos"
mkdir -p "$CARRELS/$NAME/txt"
mkdir -p "$CARRELS/$NAME/urls"
mkdir -p "$CARRELS/$NAME/wrd"
mkdir -p "$CARRELS/$NAME/log"

# fill file system
cp ./etc/README        "$CARRELS/$NAME"
cp ./etc/LICENSE       "$CARRELS/$NAME"
cp ./etc/home.html     "$CARRELS/$NAME"
cp ./etc/stopwords.txt "$CARRELS/$NAME/etc"
cp ./etc/queries.sql   "$CARRELS/$NAME/etc"
cp ./etc/reader.sql    "$CARRELS/$NAME/etc"
