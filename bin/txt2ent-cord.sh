#!/usr/bin/env bash

# txt2ent-cord.sh - a front-end to txt2ent-cord.py; a poor man's cluster implementation

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# November 18, 2020 - during a pandemic and while "practicing" in Lancaster


# configure
PATTERN='*.txt'
TXT='./cord/txt'
CORES='128'
TXT2ENT='txt2ent-cord.py'

# get a list of all the files to process
readarray -t FILES < <( find "$TXT" -name "$PATTERN" )

# count the number of files to process
COUNT=${#FILES[@]}

# calculate the size of each batch
BATCH=$((($COUNT/$CORES)+1))

# create and submit as many batches as there are cores
#for CORE in {1..32};
for CORE in {33..64};
#for CORE in {65..98};
#for CORE in {99..128};
do 

	# calculate the beginning and the end of this particular batch
	START=$((($CORE*$BATCH)-$BATCH+1))
	END=$(($START+$BATCH))

	# slice the list of files accordingly and submit them in the background
	$TXT2ENT ${FILES[@]:$START:$END} &	

# fini
done
exit

