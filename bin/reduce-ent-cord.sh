#!/usr/bin/env bash

# reduce-ent.sh - build a transaction from previously created SQL statements and fill a database table

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# May 26, 2020 - first cut


# configure
DB='./etc/cord.db'
SQLENT='./sql-ent'
TMP='./tmp'
DELETE='DELETE FROM ent;'
INSERTS='inserts-ent.sql'

# make sane
mkdir -p $TMP

# create a transaction
echo "Creating transaction" >&2
echo "BEGIN TRANSACTION;"   >  "$TMP/$INSERTS"
echo $DELETE                >> "$TMP/$INSERTS"
cat $SQLENT/cord-0*.sql     >> "$TMP/$INSERTS"
cat $SQLENT/cord-1*.sql     >> "$TMP/$INSERTS"
cat $SQLENT/cord-2*.sql     >> "$TMP/$INSERTS"
cat $SQLENT/cord-3*.sql     >> "$TMP/$INSERTS"
cat $SQLENT/cord-4*.sql     >> "$TMP/$INSERTS"
cat $SQLENT/cord-5*.sql     >> "$TMP/$INSERTS"
cat $SQLENT/cord-6*.sql     >> "$TMP/$INSERTS"
cat $SQLENT/cord-7*.sql     >> "$TMP/$INSERTS"
cat $SQLENT/cord-8*.sql     >> "$TMP/$INSERTS"
cat $SQLENT/cord-9*.sql     >> "$TMP/$INSERTS"
echo "END TRANSACTION;"     >> "$TMP/$INSERTS"

# do the work and done
echo "Updating ent table" >&2
cat "$TMP/$INSERTS" | sqlite3 $DB
exit
