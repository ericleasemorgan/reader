#!/usr/bin/env bash

# build.sh - one script to rule them all

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 16, 2020 - first cut


# on my mark, get set,... go
find json -name "*.json" | parallel ./bin/json2sql.sh 
./bin/db-initialize.sh
./bin/sql2db.sh
./bin/db2reader.sh
