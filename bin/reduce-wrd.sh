#!/usr/bin/env bash

# reduce-wrd.sh - build a transaction from previously created SQL statements and fill a database table

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# May  22, 2020 - first cut; why didn't I think of this previously!? 


# configure
DB='./etc/cord.db'
SQLWRD='./sql-wrd'
TMP='./tmp'
DELETE='DELETE FROM wrd;'
INSERTS='inserts-wrd.sql'

# make sane
mkdir -p $TMP

# create a transaction
echo "Creating transaction" >&2
echo "BEGIN TRANSACTION;"   >  "$TMP/$INSERTS"
echo $DELETE                >> "$TMP/$INSERTS"
cat $SQLWRD/cord-0*.sql    >> "$TMP/$INSERTS"
cat $SQLWRD/cord-1*.sql    >> "$TMP/$INSERTS"
cat $SQLWRD/cord-2*.sql    >> "$TMP/$INSERTS"
cat $SQLWRD/cord-3*.sql    >> "$TMP/$INSERTS"
cat $SQLWRD/cord-4*.sql    >> "$TMP/$INSERTS"
cat $SQLWRD/cord-5*.sql    >> "$TMP/$INSERTS"
cat $SQLWRD/cord-6*.sql    >> "$TMP/$INSERTS"
cat $SQLWRD/cord-7*.sql    >> "$TMP/$INSERTS"
cat $SQLWRD/cord-8*.sql    >> "$TMP/$INSERTS"
cat $SQLWRD/cord-9*.sql    >> "$TMP/$INSERTS"
echo "END TRANSACTION;"    >> "$TMP/$INSERTS"

# do the work and done
echo "Updating wrd table" >&2
cat "$TMP/$INSERTS" | sqlite3 $DB
exit
