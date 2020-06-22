#!/usr/bin/env bash

# reduce.sh - given a directory, build (reduce) a database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 28, 2018 - first cut
# June 21, 2020 - started to change how reduce works, somewhat sucessfully


# configure
CARRELS='/export/reader/carrels'
REDUCE='/export/reader/bin/reduce.pl'
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

find "$CARRELS/$NAME" -name '*.bib' -exec $REDUCE "$CARRELS/$NAME" bib {} \;
#find "$CARRELS/$NAME" -name '*.adr' -exec $REDUCE "$CARRELS/$NAME" adr {} \;
#find "$CARRELS/$NAME" -name '*.ent' -exec $REDUCE "$CARRELS/$NAME" ent {} \;
#find "$CARRELS/$NAME" -name '*.pos' -exec $REDUCE "$CARRELS/$NAME" pos {} \;
#find "$CARRELS/$NAME" -name '*.wrd' -exec $REDUCE "$CARRELS/$NAME" wrd {} \;
#find "$CARRELS/$NAME" -name '*.url' -exec $REDUCE "$CARRELS/$NAME" url {} \;

# addresses
echo "===== Reducing email addresses" >&2
cd "$CARRELS/$NAME"
mkdir -p ./tmp/sql-adr
find ./adr -name "*.adr" | $PARALLEL --will-cite /export/reader/bin/adr2sql.pl
/export/reader/bin/reduce-adr.sh

# keywords
echo "===== Reducing keywords" >&2
cd "$CARRELS/$NAME"
mkdir -p ./tmp/sql-wrd
find ./wrd -name "*.wrd" | $PARALLEL --will-cite /export/reader/bin/wrd2sql.pl
/export/reader/bin/reduce-wrd.sh

# urls
echo "===== Reducing urls" >&2
cd "$CARRELS/$NAME"
mkdir -p ./tmp/sql-url
find ./urls -name "*.url" | $PARALLEL --will-cite /export/reader/bin/url2sql.pl
/export/reader/bin/reduce-url.sh

# entities
echo "===== Reducing named entities" >&2
cd "$CARRELS/$NAME"
mkdir -p ./tmp/sql-ent
find ./ent -name "*.ent" | $PARALLEL --will-cite /export/reader/bin/ent2sql.pl
/export/reader/bin/reduce-ent.sh

# pos
echo "===== Reducing parts of speech" >&2
cd "$CARRELS/$NAME"
mkdir -p ./tmp/sql-pos
find ./pos -name "*.pos" | $PARALLEL --will-cite /export/reader/bin/pos2sql.pl
/export/reader/bin/reduce-pos.sh

