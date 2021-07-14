#!/usr/bin/env bash

# txt2pos-cord.sh - a front-end to txt2pos-cord.py; good when you have many cores on a given computer
# Usage: sbatch ./bin/txt2pos-cord.slurm

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# April 7, 2021 - first cut; inspired by Don Brower

# configure bash
TXT=./cord/txt
ITERATIONS=960
CORES=96
TXT2POS=./bin/txt2pos-cord.py

# create a list of all files, determine its size, and size of batch
FILES=( $( find $TXT -type f ) )
NUMBER_OF_FILES=${#FILES[@]}
SIZE_OF_BATCH=$((NUMBER_OF_FILES / ITERATIONS))

# loop through each iteration; tricky use of eval
for INDEX in $( eval echo {0..$ITERATIONS..$CORES} ); do

	# loop through each core
	for (( B=0; B<$CORES; B++ )); do  
   
		# calculate start
		START=$(((INDEX + B) * SIZE_OF_BATCH))
	
		# create a batch of files to process; slice the list of all files
		BATCH=("${FILES[@]:$START:$SIZE_OF_BATCH}")

		# submit the work and done
		if (( B < (CORES - 1) )); then
			echo "${BATCH[*]}" | xargs $TXT2POS &
		else
			echo "${BATCH[*]}" | xargs $TXT2POS
		fi
		
	done

# fini
done
exit
