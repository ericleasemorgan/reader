#!/bin/bash

#SBATCH -p big-cloud
#SBATCH -N 1
#SBATCH -n 24
#SBATCH --mail-user=emorgan@nd.edu
#SBATCH -t 48:0:00
#SBATCH -J ENT2SQL
#SBATCH -o ./log/ent2sql-output.txt
#SBATCH -e ./log/ent2sql-error.txt

#SBATCH --mail-type=ALL

cd /export/reader
mkdir -p ./cord/sql-ent; find ./cord/ent -name "*.ent" | parallel --will-cite ./bin/ent2sql-cord.pl
