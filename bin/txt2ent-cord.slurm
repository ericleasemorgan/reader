#!/usr/bin/env bash

# txt2ent-cord.slurm - given a few configurations, batch process a list of files
# Usage: sbatch ./bin/txt2ent-cord.slurm

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# April 7, 2021 - first cut; inspired by Don Brower
# July 11, 2021 - increase the number of nodes; maybe this really is embarrassingly parallel? 


# configure slurm
#SBATCH --array=0-1000:48
#SBATCH -J TXT2ENT
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -t 4:00:00
#SBATCH -o ./log/txt2ent-output.txt
#SBATCH -e ./log/txt2ent-error.txt
#SBATCH --mail-user=emorgan@nd.edu
#SBATCH --mail-type=ALL

# configure bash
HOME='/ocean/projects/cis210016p/shared/reader-compute/reader-cord'
TXT=./cord/txt
ITERATIONS=2000
STEPS=48
TXT2ENT=./bin/txt2ent-cord.py
INDEX=$SLURM_ARRAY_TASK_ID

# initialize; create a list of all files, determine its size, and size of batch
cd $HOME
FILES=( $( find $TXT -type f ) )
NUMBER_OF_FILES=${#FILES[@]}
SIZE_OF_BATCH=$((NUMBER_OF_FILES / ITERATIONS))

# process each step
for (( B=0; B<$STEPS; B++ )); do  
   
	# calculate start
	START=$(((INDEX + B) * SIZE_OF_BATCH))
	
	# create a batch of files to process; slice the list of all files
	BATCH=("${FILES[@]:$START:$SIZE_OF_BATCH}")

	# submit the work and done
	if (( B < (STEPS - 1) )); then
		echo "${BATCH[*]}" | xargs $TXT2ENT &
	else
		echo "${BATCH[*]}" | xargs $TXT2ENT
	fi
		
# fini
done
exit
