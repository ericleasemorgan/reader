#!/usr/bin/env bash

# carell2db.sh - given a directory, build (reduce) a database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 28, 2018 - first cut

# configure
HOME='/Users/emorgan/Desktop/reader'
CARREL2DB='./bin/carrel2db.pl'
INITIALIZEDB='./bin/initialize-database.sh'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <directory>" >&2
	exit
fi

# get input
DIRECTORY=$1

# make sane
cd $HOME

# echo and do the work
echo "$DIRECTORY" >&2
$INITIALIZEDB $DIRECTORY
find $DIRECTORY -name '*.pos' -exec ./bin/carrel2db.pl $DIRECTORY pos {} \;
find $DIRECTORY -name '*.ent' -exec ./bin/carrel2db.pl $DIRECTORY ent {} \;
find $DIRECTORY -name '*.wrd' -exec ./bin/carrel2db.pl $DIRECTORY wrd {} \;
find $DIRECTORY -name '*.adr' -exec ./bin/carrel2db.pl $DIRECTORY adr {} \;
find $DIRECTORY -name '*.url' -exec ./bin/carrel2db.pl $DIRECTORY url {} \;
find $DIRECTORY -name '*.bib' -exec ./bin/carrel2db.pl $DIRECTORY bib {} \;
