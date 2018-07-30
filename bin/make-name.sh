#!/usr/bin/env bash

# make-name.sh - generate a (random) study carrel name

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 16, 2018 - first cut; needs error checking


# do the work, output, and done
NAME=$( cat /dev/urandom | tr -cd 'a-zA-Z' | head -c 7 )
echo -n $NAME
exit