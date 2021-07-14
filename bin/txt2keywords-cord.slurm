#!/usr/bin/env bash

# txt2keywords-cord.slurm - given a few configurations, batch process a list of files
# Usage: sbatch ./bin/txt2keywords-cord.slurm

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# April 7, 2021 - first cut; inspired by Don Brower


# configure slurm
#SBATCH --array=0-1000:48
#SBATCH -J TXT2WRD
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -t 3:00:00
#SBATCH -o ./log/txt2keyword-output.txt
#SBATCH -e ./log/txt2keyword-error.txt
#SBATCH --mail-user=emorgan@nd.edu

# configure bash
HOME='/ocean/projects/cis210016p/shared/reader-compute/reader-cord'
TXT=./cord/txt
ITERATIONS=1000
STEPS=48
TXT2KEYWORD=./bin/txt2keywords-cord.py
INDEX=$SLURM_ARRAY_TASK_ID

# create a list of all files, determine its size, and size of batch
cd $HOME
FILES=( $( find $TXT -type f ) )
NUMBER_OF_FILES=${#FILES[@]}
SIZE_OF_BATCH=$((NUMBER_OF_FILES / ITERATIONS))

for (( B=0; B<$STEPS; B++ )); do  
   
	# calculate start
	START=$(((INDEX + B) * SIZE_OF_BATCH))
	
	# create a batch of files to process; slice the list of all files
	BATCH=("${FILES[@]:$START:$SIZE_OF_BATCH}")

	# submit the work and done
	if (( B < (STEPS - 1) )); then
		echo "${BATCH[*]}" | xargs $TXT2KEYWORD &
	else
		echo "${BATCH[*]}" | xargs $TXT2KEYWORD
	fi
		
# fini
done
exit
