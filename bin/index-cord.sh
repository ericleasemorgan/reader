#!/usr/bin/env bash

# index.sh - create full text index of a configured database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# August   26, 2022 - first cut; while waiting for my flight to Lyon
# December 11, 2022 - making work with a limit number of articles from CORD


# configure
DB='./etc/cord.db'
DROPINDX='DROP TABLE IF EXISTS indx;'
CREATEINDX='CREATE VIRTUAL TABLE indx USING FTS5( identifier, author, title, date, journal, abstract, keywords, details, url );'
INDEX="INSERT INTO indx SELECT 'cord-'||(substr('0000000'||d.document_id, -7, 7))||'-'||d.cord_uid, d.authors, d.title, d.date, d.journal, d.abstract, GROUP_CONCAT( w.keyword, '; ' ), d.url, 'https://distantreader.org/stacks/cord/cord-'||(substr('0000000'||d.document_id, -7, 7))||'-'||d.cord_uid||'.txt' FROM documents as d, wrd as w WHERE d.document_id is w.document_id group by w.document_id;"

# index; do the actual work
echo "Dropping index..." >&2
echo $DROPINDX   | sqlite3 $DB

echo "Creating index..." >&2
echo $CREATEINDX | sqlite3 $DB

echo "Indexing..." >&2
echo $INDEX      | sqlite3 $DB

# done
exit
