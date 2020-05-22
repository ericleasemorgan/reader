#!/usr/bin/env bash

# sql2db.sh - given a set of SQL file, fill a database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 16, 2020 - first cut

# configure
DB='./etc/cord.db'
SQL='./sql'
TMP='./tmp'

# make sane
mkdir -p $TMP

# create a transaction
echo "BEGIN TRANSACTION;" >  "$TMP/inserts.sql"
cat $SQL/0*.sql           >> "$TMP/inserts.sql"
cat $SQL/1*.sql           >> "$TMP/inserts.sql"
cat $SQL/2*.sql           >> "$TMP/inserts.sql"
cat $SQL/3*.sql           >> "$TMP/inserts.sql"
cat $SQL/4*.sql           >> "$TMP/inserts.sql"
cat $SQL/5*.sql           >> "$TMP/inserts.sql"
cat $SQL/6*.sql           >> "$TMP/inserts.sql"
cat $SQL/7*.sql           >> "$TMP/inserts.sql"
cat $SQL/8*.sql           >> "$TMP/inserts.sql"
cat $SQL/9*.sql           >> "$TMP/inserts.sql"
echo "END TRANSACTION;"   >> "$TMP/inserts.sql"

# do the work and done
cat "$TMP/inserts.sql" | sqlite3 $DB
exit
