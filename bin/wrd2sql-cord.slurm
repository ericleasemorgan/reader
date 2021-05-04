#!/bin/bash

# wrd2sql-cord.slurm - an sbatch script to convert TSV files to SQL

# Eric Lease Morgan <emorgan@nd.edu>
# July 21, 2020 - first cut; needs to be improved to all the cores in the cluster can be used


#SBATCH --mail-type=ALL
#SBATCH --mail-user=emorgan@nd.edu
#SBATCH -e ./log/wrd2sql-error.txt
#SBATCH -J WRD2SQL
#SBATCH -N 1
#SBATCH -n 24
#SBATCH -o ./log/wrd2sql-output.txt
#SBATCH -p big-cloud
#SBATCH -t 48:0:00

cd /export/reader
mkdir -p ./cord/sql-wrd; find ./cord/wrd -name "*.wrd" | parallel --will-cite ./bin/wrd2sql-cord.pl
