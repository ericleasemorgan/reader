#!/usr/bin/env bash

# map.sh - given an directory (of .txt files), map various types of information

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June    27, 2018 - first cut
# July    10, 2018 - started using parallel, and removed files2txt processing
# July    12, 2018 - migrating to the cluster
# February 3, 2020 - tweaked a lot to accomodate large files


# configure
TXT='txt';
CACHE='cache'
PARALLEL='/export/bin/parallel'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# initialize
NAME=$1
INPUT="$TXT"

# extract addresses, urls, and keywords
find "$INPUT" -name '*.txt' | $PARALLEL --will-cite /export/reader/bin/txt2adr.sh {}      &
find "$INPUT" -name '*.txt' | $PARALLEL --will-cite /export/reader/bin/txt2urls.sh {}     &
wait

# extract bibliographics
#find "$CACHE" -type f | $PARALLEL -j 7 --will-cite /export/reader/bin/file2bib.sh {} &
find "$CACHE" -type f | $PARALLEL --will-cite /export/reader/bin/file2bib.sh {} &
wait

# set up multi-threading environment
OMP_NUM_THREADS=1
OPENBLAS_NUM_THREADS=1
MKL_NUM_THREADS=1
export OMP_NUM_THREADS
export OPENBLAS_NUM_THREADS
export MKL_NUM_THREADS

# extract parts-of-speech and named-entities
find "$INPUT" -name '*.txt' | $PARALLEL --will-cite /export/reader/bin/txt2ent.sh {} &
wait
find "$INPUT" -name '*.txt' | $PARALLEL --will-cite /export/reader/bin/txt2pos.sh {} &
wait

# set up multi-threading environment, again
OMP_NUM_THREADS=3
OPENBLAS_NUM_THREADS=3
MKL_NUM_THREADS=3
export OMP_NUM_THREADS
export OPENBLAS_NUM_THREADS
export MKL_NUM_THREADS

#find "$INPUT" -name '*.txt' | $PARALLEL -j 3 --will-cite /export/reader/bin/txt2keywords.sh {} &
find "$INPUT" -name '*.txt' | $PARALLEL --will-cite /export/reader/bin/txt2keywords.sh {} &
wait

# done
echo "Que is empty; done" >&2
exit
