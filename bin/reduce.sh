#!/usr/bin/env bash

# reduce.sh - given a directory, build (reduce) a database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 28, 2018 - first cut
# June 21, 2020 - started to change how reduce works, somewhat sucessfully


# configure
CARRELS="$READERCORD_HOME/carrels"
REDUCE='reduce.pl'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# get input
NAME=$1

# echo and do the work
echo "$NAME" >&2

find "$CARRELS/$NAME" -name '*.bib' -exec $REDUCE "$CARRELS/$NAME" bib {} \;

# addresses
echo "===== Reducing email addresses" >&2
cd "$CARRELS/$NAME"
mkdir -p ./tmp/sql-adr
find ./adr -name "*.adr" | parallel adr2sql.pl
reduce-adr.sh

# keywords
echo "===== Reducing keywords" >&2
cd "$CARRELS/$NAME"
mkdir -p ./tmp/sql-wrd
find ./wrd -name "*.wrd" | parallel wrd2sql.pl
reduce-wrd.sh

# urls
echo "===== Reducing urls" >&2
cd "$CARRELS/$NAME"
mkdir -p ./tmp/sql-url
find ./urls -name "*.url" | parallel url2sql.pl
reduce-url.sh

# entities
echo "===== Reducing named entities" >&2
cd "$CARRELS/$NAME"
mkdir -p ./tmp/sql-ent
find ./ent -name "*.ent" | parallel ent2sql.pl
reduce-ent.sh

# pos
echo "===== Reducing parts of speech" >&2
cd "$CARRELS/$NAME"
mkdir -p ./tmp/sql-pos
find ./pos -name "*.pos" | parallel pos2sql.pl
reduce-pos.sh

