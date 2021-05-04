#!/usr/bin/env bash

# reduce-ent.sh - build a transaction from previously created SQL statements and fill a database table

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# May  22, 2020 - first cut; why didn't I think of this previously!? 


# configure
DB='./etc/reader.db'
SQLENT='./tmp/sql-ent'
TMP='./tmp'
DELETE='DELETE FROM ent;'
INSERTS='inserts-ent.sql'

# make sane
mkdir -p $TMP

# create a transaction
echo "Creating transaction" >&2
echo "BEGIN TRANSACTION;"   >  "$TMP/$INSERTS"
echo $DELETE                >> "$TMP/$INSERTS"
find "$SQLENT" -type f -name "cord-*.sql" -exec cat {} \+ >> "$TMP/$INSERTS"
echo "END TRANSACTION;"    >> "$TMP/$INSERTS"

# do the work and done
echo "Updating ent table" >&2
cat "$TMP/$INSERTS" | sqlite3 $DB
exit
