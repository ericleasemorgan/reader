#!/usr/bin/env bash

# sql2db.sh - given a set of SQL file, fill a database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 16, 2020 - first cut

# configure
DB="./etc/cord.db"
SQL="./cord/sql"
TMP="./tmp"
INSERTS='inserts-cord.sql'

# make sane
mkdir -p $TMP

echo "BEGIN TRANSACTION;"                         >  "$TMP/$INSERTS"
find "$SQL" -type f -name "*.sql" -exec cat {} \+ >> "$TMP/$INSERTS"
echo "END TRANSACTION;"                           >> "$TMP/$INSERTS"

# do the work and done
cat "$TMP/$INSERTS" | sqlite3 $DB
exit
