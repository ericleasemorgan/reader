#!/bin/bash

#SBATCH -p cloud
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mail-user=emorgan@nd.edu
#SBATCH -t 48:0:00
#SBATCH -J JSON2CORPUS
#SBATCH -o ./log/standard-output.txt
#SBATCH -e ./log/standard-error.txt

#SBATCH --mail-type=ALL

cd /export/cord
mkdir -p ./txt; find json -type f -not -name "P*" | sort | parallel ./bin/json2corpus.sh
