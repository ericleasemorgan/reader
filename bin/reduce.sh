#!/usr/bin/env bash

# carell2db.sh - given a directory, build (reduce) a database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 28, 2018 - first cut

# configure
CARRELS='./carrels'
HOME=$READER_HOME
REDUCE='./bin/reduce.pl'
INITIALIZEDB='./bin/initialize-database.sh'
PARALLEL='/usr/bin/parallel'
JOBS=40

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
find "$CARRELS/$NAME" -name '*.pos' | $PARALLEL --jobs $JOBS  $REDUCE "$CARRELS/$NAME" pos {} \;
find "$CARRELS/$NAME" -name '*.ent' | $PARALLEL --jobs $JOBS  $REDUCE "$CARRELS/$NAME" ent {} \;
find "$CARRELS/$NAME" -name '*.wrd' | $PARALLEL --jobs $JOBS  $REDUCE "$CARRELS/$NAME" wrd {} \;
find "$CARRELS/$NAME" -name '*.adr' | $PARALLEL --jobs $JOBS  $REDUCE "$CARRELS/$NAME" adr {} \;
find "$CARRELS/$NAME" -name '*.url' | $PARALLEL --jobs $JOBS  $REDUCE "$CARRELS/$NAME" url {} \;
find "$CARRELS/$NAME" -name '*.bib' | $PARALLEL --jobs $JOBS  $REDUCE "$CARRELS/$NAME" bib {} \;
