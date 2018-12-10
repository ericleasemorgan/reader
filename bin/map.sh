#!/usr/bin/env bash

# map.sh - given an directory (of .txt files), map various types of information

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 27, 2018 - first cut
# July 10, 2018 - started using parallel, and removed files2txt processing
# July 12, 2018 - migrating to the cluster


# configure
CARRELS='./carrels'
HOME='/home/emorgan/reader'
TXT='/txt';
NETID='emorgan'
JOBS=40
#PARALLEL='/afs/crc.nd.edu/user/e/emorgan/bin/parallel'
#QSTAT='/opt/sge/bin/lx-amd64/qstat'
#QSUB='/opt/sge/bin/lx-amd64/qsub'

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
find $INPUT -name '*.txt' | parallel --jobs $JOBS  ./bin/txt2adr.sh {}
find $INPUT -name '*.txt' | parallel --jobs $JOBS  ./bin/txt2bib.sh {}
find $INPUT -name '*.txt' | parallel --jobs $JOBS  ./bin/txt2ent.sh {}
find $INPUT -name '*.txt' | parallel --jobs $JOBS  ./bin/txt2pos.sh {}
find $INPUT -name '*.txt' | parallel --jobs $JOBS  ./bin/txt2keywords.sh {}
find $INPUT -name '*.txt' | parallel --jobs $JOBS  ./bin/txt2urls.sh {}

# done
echo "Que is empty; done" >&2
exit


