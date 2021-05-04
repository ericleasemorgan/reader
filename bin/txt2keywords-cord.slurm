#!/bin/bash

# txt2keywords-cord.slurm - given a list of plain text file names, output set of keyword files

# Don Brower <dbrower@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# August 12, 2020 - first documentation


# configure slurm
#SBATCH -p big-cloud
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user=emorgan@nd.edu
#SBATCH -t 48:0:00
#SBATCH -J TXT2KEYWORDS
#SBATCH --array=0-100
#SBATCH -o ./log/txt2keyword-output.txt
#SBATCH -e ./log/txt2keyword-error.txt
#SBATCH --mail-type=ALL

# configure bash
HOME=/export/reader
KEYWORDS=./cord/wrd
TXT=./cord/txt
TODO=./tmp/txt2keywords-todo.txt
TXT2KEYWORD=./bin/txt2keywords-cord.py

# make sane
cd $HOME
mkdir -p $KEYWORDS

echo "start $(date -Iseconds) array $SLURM_ARRAY_TASK_ID" >&2

# Split the files into groups, and each slurm node will work on a single group.
# Node 0 does the split, and all the others will use the file.
#
# To change the number of nodes, adjust the sbatch -N line above.
if [[ $SLURM_ARRAY_TASK_ID -eq 0 ]]; then

    find $TXT -name '*.txt'  >  $TODO
    echo "DONE"              >> $TODO

else
    # Since I'm unsure how to signal the other nodes to read the file and
    # start working, have the other nodes sleep for at least 30 seconds
    # and check for the last line of "DONE" before starting.
    # The 30 seconds is arbitrary.
    # This doesn't use a loop so it is guaranteed to terminate.
    sleep 30
    if [ DONE != $(tail -n 1 $TODO) ]; then
        sleep 30
    fi
    if [ DONE != $(tail -n 1 $TODO) ]; then
        sleep 30
    fi
    if [ DONE != $(tail -n 1 $TODO) ]; then
        sleep 30
    fi
    if [ DONE != $(tail -n 1 $TODO) ]; then
        sleep 30
    fi
    if [ DONE != $(tail -n 1 $TODO) ]; then
        sleep 30
    fi
    if [ DONE != $(tail -n 1 $TODO) ]; then
        echo "$TODO is not DONE"
        exit 1
    fi
fi

# each array task does a (disjoint) section of the work
#
# add 1 to the start line since sed lines numbers are 1-based
NUM_LINES=$(cat $TODO | wc -l)
START_LINE=$(( NUM_LINES * SLURM_ARRAY_TASK_ID / SLURM_ARRAY_TASK_COUNT + 1 ))
STOP_LINE=$(( NUM_LINES * (SLURM_ARRAY_TASK_ID + 1) / SLURM_ARRAY_TASK_COUNT ))

sed -n "${START_LINE},${STOP_LINE}p" $TODO | grep -v DONE | xargs $TXT2KEYWORD

echo "end $(date -Iseconds) array $SLURM_ARRAY_TASK_ID" >&2

