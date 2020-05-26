#!/bin/bash

#SBATCH -p cloud
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mail-user=emorgan@nd.edu
#SBATCH -t 48:0:00
#SBATCH -J ENT2SQL
#SBATCH -o ./log/ent2sql-output.txt
#SBATCH -e ./log/ent2sql-error.txt

#SBATCH --mail-type=ALL

cd /export/cord
mkdir -p ./sql-ent; find ./ent -name "*.ent" | sort | parallel ./bin/ent2sql.sh
