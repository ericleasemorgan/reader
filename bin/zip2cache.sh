#!/usr/bin/env bash

# zip2cache.sh - given the name of a study carrel, fill the cache with the contents of a .zip file

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# May 22, 2019 - first cut


# configure
CARRELS='/export/reader/carrels'
PARALLEL='/export/bin/parallel'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# get input and make sane
NAME=$1
cd "$CARRELS/$NAME"

# initialize temporary file system and unzip
rm -rf ./tmp/input
mkdir ./tmp/input
unzip input.zip -d ./tmp/input -x '*MACOSX*'

# copy known file types to the cache; normalize file names here
find tmp/input -name "*.pdf"  | $PARALLEL --will-cite mv {} cache
find tmp/input -name "*.htm"  | $PARALLEL --will-cite mv {} cache
find tmp/input -name "*.html" | $PARALLEL --will-cite mv {} cache
find tmp/input -name "*.txt"  | $PARALLEL --will-cite mv {} cache
find tmp/input -name "*.doc"  | $PARALLEL --will-cite mv {} cache
find tmp/input -name "*.docx" | $PARALLEL --will-cite mv {} cache
find tmp/input -name "*.pptx" | $PARALLEL --will-cite mv {} cache

# done
exit
