#!/bin/bash

#SBATCH -p big-cloud
#SBATCH -N 1
#SBATCH -n 24
#SBATCH --mail-user=emorgan@nd.edu
#SBATCH -t 48:0:00
#SBATCH -J JSON2CORPUS
#SBATCH -o ./log/standard-output.txt
#SBATCH -e ./log/standard-error.txt

#SBATCH --mail-type=ALL

cd $READERCORD_HOME
mkdir -p ./cord/txt; find cord/json -type f -not -name "P*" | sort | parallel --will-cite json2corpus.sh
