#!/usr/bin/env bash

# summarize.sh - given a set of SQL, output a report

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# May 14, 2020 - first cut

DB='./etc/cord.db'
SQL='./etc/summarize.sql';

cat $SQL | sqlite3 $DB
exit
