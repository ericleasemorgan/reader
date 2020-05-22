#!/usr/bin/env bash

# build.sh - one script to rule them all

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 16, 2020 - first cut
# March 20, 2020 - added caching
# May   14, 2020 - added summary report, and removed conversation to plain text


# on my mark, get set,... go

echo "Caching" >&2
./bin/cache.sh

echo "Extracting metadata" >&2
./bin/metadata2sql.py

echo "Initializing database" >&2
./bin/db-initialize.sh

echo "Filling database" >&2
./bin/sql2db.sh

echo "Summarizing" >&2
./bin/summarize.sh > ./report.txt

echo "Done" >&2
exit
