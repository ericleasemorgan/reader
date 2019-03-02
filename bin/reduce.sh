#!/usr/bin/env bash

# carell2db.sh - given a directory, build (reduce) a database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 28, 2018 - first cut

# configure
CARRELS='/export/reader/carrels'
REDUCE='/export/reader/bin/reduce.pl'
INITIALIZEDB='/export/reader/bin/initialize-database.sh'
PARALLEL='/export/bin/parallel'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# get input
NAME=$1

# echo and do the work
echo "$NAME" >&2

$INITIALIZEDB "$CARRELS/$NAME"
find "$CARRELS/$NAME" -name '*.pos' -exec $REDUCE "$CARRELS/$NAME" pos {} \;
find "$CARRELS/$NAME" -name '*.ent' -exec $REDUCE "$CARRELS/$NAME" ent {} \;
find "$CARRELS/$NAME" -name '*.wrd' -exec $REDUCE "$CARRELS/$NAME" wrd {} \;
find "$CARRELS/$NAME" -name '*.adr' -exec $REDUCE "$CARRELS/$NAME" adr {} \;
find "$CARRELS/$NAME" -name '*.url' -exec $REDUCE "$CARRELS/$NAME" url {} \;
find "$CARRELS/$NAME" -name '*.bib' -exec $REDUCE "$CARRELS/$NAME" bib {} \;
