#!/usr/bin/env bash

# map.sh - given an directory (of .txt files), map various types of information

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 27, 2018 - first cut
# July 10, 2018 - started using parallel, and removed files2txt processing
# July 12, 2018 - migrating to the cluster


# configure
CARRELS='./carrels'
HOME=$READER_HOME
TXT='/txt';
JOBS=12
PARALLEL='/export/bin/parallel'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# initialize
NAME=$1
INPUT="$CARRELS/$NAME$TXT"
CONTINUE=0

# make sane
cd $HOME

# submit the work
find $INPUT -name '*.txt' | $PARALLEL --will-cite ./bin/txt2adr.sh {}
find $INPUT -name '*.txt' | $PARALLEL --will-cite ./bin/txt2bib.sh {} \;
find $INPUT -name '*.txt' | $PARALLEL --will-cite ./bin/txt2ent.sh {} \;
find $INPUT -name '*.txt' | $PARALLEL --will-cite ./bin/txt2pos.sh {} \;
find $INPUT -name '*.txt' | $PARALLEL --will-cite ./bin/txt2keywords.sh {} \;
find $INPUT -name '*.txt' | $PARALLEL --will-cite ./bin/txt2urls.sh {} \;

# done
echo "Que is empty; done" >&2
exit


