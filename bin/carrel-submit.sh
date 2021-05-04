#!/usr/bin/env bash

# carrel-submit.sh - given the name of a previously initialized carrel, submit process to Slurm

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# April 4, 2020 - first cut; while self-isolating at the cabin
# June  2, 2020 - added email address
# June  3, 2020 - added partition and number of cores


# configure
CARRELS="$READERCORD_HOME/carrels"
TEMPLATE='./etc/template.slurm'
SLURM='make-carrel.slurm'
BIG=20
SMALL=10

# sanity check
if [[ -z $1  || -z $2 || -z $3 ]]; then 
	echo "Usage: $0 <name> <cloud|big-cloud> <email>" >&2
	exit
fi

# get input
NAME=$1
PARTITION=$2
EMAIL=$3

# configure the number of cores to use
if   [[ $PARTITION == 'big-cloud' ]]; then CORES=$BIG
elif [[ $PARTITION == 'cloud' ]];     then CORES=$SMALL
else echo "Usage: $0 <name> <cloud|big-cloud> <email>" >&2; exit
fi

# create the batch file and move it into place
cat $TEMPLATE | sed "s/##NAME##/$NAME/g" |           \
                sed "s/##PARTITION##/$PARTITION/g" | \
                sed "s/##CORES##/$CORES/g" |           \
                sed "s/##EMAIL##/$EMAIL/g" > "$CARRELS/$NAME/$SLURM"

# make sane, submit the job, and done
cd "$CARRELS/$NAME"
sbatch $SLURM
exit
