#!/usr/bin/env bash

# build.sh - one script to rule them all

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 16, 2020 - first cut
# March 20, 2020 - added caching
# May   14, 2020 - added summary report, and removed conversation to plain text
# June   3, 2020 - added with keyword and entities data, but they really won't work unless there was pre-processing


# on my mark, get set,... go

echo "Caching" >&2
./bin/cache.sh

echo "Extracting metadata" >&2
./bin/metadata2sql.py

echo "Initializing database" >&2
./bin/db-initialize.sh

echo "Filling documents table" >&2
./bin/sql2db.sh

echo "Filling authors table" >&2
cat ./etc/authors2author.sql | sqlite3 ./etc/cord.db

echo "Filling sources table" >&2
cat ./etc/sources2source.sql | sqlite3 ./etc/cord.db

echo "Filling urls table" >&2
cat ./etc/urls2url.sql | sqlite3 ./etc/cord.db

echo "Filling shas table" >&2
cat ./etc/shas2sha.sql | sqlite3 ./etc/cord.db

echo "Filling keywords table" >&2
./bin/reduce-wrd.sh

echo "Filling named entities table" >&2
./bin/reduce-ent.sh

echo "Summarizing" >&2
./bin/summarize.sh > ./report.txt

echo "Done" >&2
exit
