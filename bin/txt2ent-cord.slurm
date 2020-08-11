#!/bin/bash

#SBATCH -p big-cloud
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user=emorgan@nd.edu
#SBATCH -t 48:0:00
#SBATCH -J TXT2ENT
#SBATCH --array=0-100
#SBATCH -o ./log/txt2ent-output.txt
#SBATCH -e ./log/txt2ent-error.txt

#SBATCH --mail-type=ALL

cd /export/reader

echo "start $(date -Iseconds) array $SLURM_ARRAY_TASK_ID" >&2

# Split the files into groups, and each slurm node will work on a single group.
# Node 0 does the split, and all the others will use the file.
#
# To change the number of nodes, adjust the sbatch -N line above.
WORK_LIST=./cord/WORK_TXT2ENT
if [[ $SLURM_ARRAY_TASK_ID -eq 0 ]]; then
    # I guess this assumes that array job 0 is the first to run.
    # That may be a bad assumption.
    mkdir -p ./cord/ent
    find ./cord/txt -name '*.txt' > $WORK_LIST
    echo "DONE" >> $WORK_LIST
else
    # Since I'm unsure how to signal the other nodes to read the file and
    # start working, have the other nodes sleep for at least 30 seconds
    # and check for the last line of "DONE" before starting.
    # The 30 seconds is arbitrary.
    # This doesn't use a loop so it is guaranteed to terminate.
    sleep 30
    if [ DONE != $(tail -n 1 $WORK_LIST) ]; then
        sleep 30
    fi
    if [ DONE != $(tail -n 1 $WORK_LIST) ]; then
        sleep 30
    fi
    if [ DONE != $(tail -n 1 $WORK_LIST) ]; then
        sleep 30
    fi
    if [ DONE != $(tail -n 1 $WORK_LIST) ]; then
        sleep 30
    fi
    if [ DONE != $(tail -n 1 $WORK_LIST) ]; then
        sleep 30
    fi
    if [ DONE != $(tail -n 1 $WORK_LIST) ]; then
        echo "$WORK_LIST is not DONE"
        exit 1
    fi
fi

# each array task does a (disjoint) section of the work
#
# add 1 to the start line since sed lines numbers are 1-based
NUM_LINES=$(cat $WORK_LIST | wc -l)
START_LINE=$(( NUM_LINES * SLURM_ARRAY_TASK_ID / SLURM_ARRAY_TASK_COUNT + 1 ))
STOP_LINE=$(( NUM_LINES * (SLURM_ARRAY_TASK_ID + 1) / SLURM_ARRAY_TASK_COUNT ))

sed -n "${START_LINE},${STOP_LINE}p" $WORK_LIST | grep -v DONE | xargs ./bin/txt2ent-cord.py

echo "end $(date -Iseconds) array $SLURM_ARRAY_TASK_ID" >&2
