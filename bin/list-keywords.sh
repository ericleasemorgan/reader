#!/usr/bin/env bash

# list-keywords.sh - output a frequency list of keywords

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# December 10, 2022 - first investigations

DB='./etc/cord-2022-12-09.db'
SQL='.mode tabs\nselect lower(keyword), count( lower(keyword) ) as c from wrd group by lower(keyword) order by c desc limit 9999;'

echo -e $SQL | sqlite3 $DB


