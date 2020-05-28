#!/bin/bash

#SBATCH -p cloud
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mail-user=emorgan@nd.edu
#SBATCH -t 48:0:00
#SBATCH -J WRD2SQL
#SBATCH -o ./log/wrd2sql-output.txt
#SBATCH -e ./log/wrd2sql-error.txt

#SBATCH --mail-type=ALL

cd /export/cord
mkdir -p ./sql-wrd; find ./wrd -name "*.wrd" | sort | parallel ./bin/wrd2sql.sh
