#!/usr/bin/env bash

# db-initialize.sh - create a database to hold basic bibliographics, very basic

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 16, 2020 - first cut


# configure
DB='./etc/cord.db'
SCHEMA='./etc/schema-cord.sql'

# make sane
rm -rf $DB

# do the work and done
cat $SCHEMA | sqlite3 $DB
exit
