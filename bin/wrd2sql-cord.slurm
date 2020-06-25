#!/bin/bash

#SBATCH --mail-type=ALL
#SBATCH --mail-user=emorgan@nd.edu
#SBATCH -e ./log/wrd2sql-error.txt
#SBATCH -J WRD2SQL
#SBATCH -N 1
#SBATCH -n 24
#SBATCH -o ./log/wrd2sql-output.txt
#SBATCH -p big-cloud
#SBATCH -t 48:0:00

cd /export/cord
mkdir -p ./cord/sql-wrd; find ./cord/wrd -name "*.wrd" | parallel --will-cite ./bin/wrd2sql-cord.pl
