#!/usr/bin/env bash

# build.sh - one script to rule them all

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 16, 2020 - first cut
# March 20, 2020 - added caching
# May   14, 2020 - added summary report, and removed conversation to plain text


# on my mark, get set,... go
./bin/cache.sh
./bin/metadata2sql.py
./bin/db-initialize.sh
./bin/sql2db.sh
./bin/summarize.sh > ./report.txt
