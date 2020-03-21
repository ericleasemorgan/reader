#!/usr/bin/env bash

# build.sh - one script to rule them all

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 16, 2020 - first cut
# March 20, 2020 - added caching


# on my mark, get set,... go
./bin/cache.sh
./bin/db-initialize.sh
./bin/metadata2sql.py
./bin/sql2db.sh
find json -name "*.json" | parallel ./bin/json2txt.sh 
./bin/db2reader.sh
