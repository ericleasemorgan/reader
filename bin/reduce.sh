#!/usr/bin/env bash

# carell2db.sh - given a directory, build (reduce) a database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 28, 2018 - first cut

# configure
CARRELS='./carrels'
HOME='/afs/crc.nd.edu/user/e/emorgan/local/reader'
REDUCE='./bin/reduce.pl'
INITIALIZEDB='./bin/initialize-database.sh'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# get input
NAME=$1

# make sane
cd $HOME

# echo and do the work
echo "$NAME" >&2

$INITIALIZEDB "$CARRELS/$NAME"
find "$CARRELS/$NAME" -name '*.pos' | parallel $REDUCE "$CARRELS/$NAME" pos {} \;
find "$CARRELS/$NAME" -name '*.ent' | parallel $REDUCE "$CARRELS/$NAME" ent {} \;
find "$CARRELS/$NAME" -name '*.wrd' | parallel $REDUCE "$CARRELS/$NAME" wrd {} \;
find "$CARRELS/$NAME" -name '*.adr' | parallel $REDUCE "$CARRELS/$NAME" adr {} \;
find "$CARRELS/$NAME" -name '*.url' | parallel $REDUCE "$CARRELS/$NAME" url {} \;
find "$CARRELS/$NAME" -name '*.bib' | parallel $REDUCE "$CARRELS/$NAME" bib {} \;
