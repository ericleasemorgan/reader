#!/usr/bin/env bash

# carrel-submit.sh - given the name of a previously initialized carrel, submit process to Slurm

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# April 4, 2020 - first cut; while self-isolating at the cabin


# configure
CARRELS='/export/reader/carrels'
TEMPLATE='./etc/cord-small.slurm'
SLURM="cord.slurm"

if [[ -z $1 ]]; then 
	echo "Usage: $0 <name>" >&2
	exit
fi

# get input
NAME=$1

# create the batch file and move it into place
cat $TEMPLATE | sed "s/##NAME##/$NAME/" > $CARRELS/$NAME/$SLURM

# make sane, submit the job, and done
cd "$CARRELS/$NAME"
sbatch $SLURM
exit
