#!/usr/bin/env bash

# map.sh - given an directory (of .txt files), map various types of information

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 27, 2018 - first cut
# July 10, 2018 - started using parallel, and removed files2txt processing
# July 12, 2018 - migrating to the cluster


# configure
CARRELS='./carrels'
HOME='/afs/crc.nd.edu/user/e/emorgan/local/reader'
TXT='/txt';
NETID='emorgan'

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
find $INPUT -name '*.txt' | parallel ./bin/txt2adr.sh {}
find $INPUT -name '*.txt' -exec qsub -N "$NAME" -o ./log/txt2bib.log ./bin/txt2bib.sh {} \;
find $INPUT -name '*.txt' -exec qsub -N "$NAME" -o ./log/txt2ent.log ./bin/txt2ent.sh {} \;
find $INPUT -name '*.txt' -exec qsub -N "$NAME" -o ./log/txt2pos.log ./bin/txt2pos.sh {} \;
find $INPUT -name '*.txt' -exec qsub -N "$NAME" -o ./log/txt2wrd.log ./bin/txt2keywords.sh {} \;
find $INPUT -name '*.txt' | parallel ./bin/txt2urls.sh {}

# start waiting
while [ $CONTINUE -eq 0 ]; do

	# get and check the queue
	QUE=$( qstat -u $NETID | grep $NAME | wc -l )
	if [ $QUE -eq 0 ]; then
		
		# let the file system catch up?; rest some more
		sleep 20
		CONTINUE=1
	else
		
		# continue waiting
		printf "Items in the queue ($NAME): $QUE     \r" >&2
		sleep 1
	fi
	
done

# done
echo "Que is empty; done" >&2
exit


