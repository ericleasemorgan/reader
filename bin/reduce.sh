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
PARALLEL='/afs/crc.nd.edu/user/e/emorgan/bin/parallel'

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
find "$CARRELS/$NAME" -name '*.pos' | $PARALLEL $REDUCE "$CARRELS/$NAME" pos {} \;
find "$CARRELS/$NAME" -name '*.ent' | $PARALLEL $REDUCE "$CARRELS/$NAME" ent {} \;
find "$CARRELS/$NAME" -name '*.wrd' | $PARALLEL $REDUCE "$CARRELS/$NAME" wrd {} \;
find "$CARRELS/$NAME" -name '*.adr' | $PARALLEL $REDUCE "$CARRELS/$NAME" adr {} \;
find "$CARRELS/$NAME" -name '*.url' | $PARALLEL $REDUCE "$CARRELS/$NAME" url {} \;
find "$CARRELS/$NAME" -name '*.bib' | $PARALLEL $REDUCE "$CARRELS/$NAME" bib {} \;
