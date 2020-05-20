#!/usr/bin/env bash

# reduce.sh - given sets of TSV files, reduce them to a database; a front-end to reduce.pl

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 28, 2018 - first cut
# May  20, 2020 - migrating to Reader CORD

# configure
REDUCE='./bin/reduce.pl'

# submit the work
find "./wrd" -name '*.wrd' -exec $REDUCE wrd {} \;
