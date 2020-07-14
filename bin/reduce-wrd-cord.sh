#!/usr/bin/env bash

# reduce-wrd.sh - build a transaction from previously created SQL statements and fill a database table

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# May  22, 2020 - first cut; why didn't I think of this previously!? 


# configure
DB='./etc/cord.db'
SQLWRD='./cord/sql-wrd'
TMP='./tmp'
DELETE='DELETE FROM wrd;'
INSERTS='inserts-wrd-cord.sql'

# make sane
mkdir -p $TMP

# create a transaction
echo "Creating transaction" >&2
echo "BEGIN TRANSACTION;"                                 >  "$TMP/$INSERTS"
echo $DELETE                                              >> "$TMP/$INSERTS"
find "$SQLWRD" -type f -name "cord-*.sql" -exec cat {} \+ >> "$TMP/$INSERTS"
echo "END TRANSACTION;"                                   >> "$TMP/$INSERTS"

# do the work and done
echo "Updating wrd table" >&2
cat "$TMP/$INSERTS" | sqlite3 $DB
exit
