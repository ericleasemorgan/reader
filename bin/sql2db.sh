#!/usr/bin/env bash

# sql2db.sh - given a set of SQL file, fill a database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 16, 2020 - first cut
# July   3, 2021 - added a tiny bit of debugging


# configure
DB="./etc/cord.db"
SQL="./cord/sql"
TMP="./tmp"
INSERTS='inserts-cord.sql'

# make sane
mkdir -p $TMP

echo "===== Creating transaction =====" >&2
echo "BEGIN TRANSACTION;"                         >  "$TMP/$INSERTS"
find "$SQL" -type f -name "*.sql" -exec cat {} \+ >> "$TMP/$INSERTS"
echo "END TRANSACTION;"                           >> "$TMP/$INSERTS"

# do the work and done
echo "===== Executing transaction =====" >&2
cat "$TMP/$INSERTS" | sqlite3 $DB
exit
