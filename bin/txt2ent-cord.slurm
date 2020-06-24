#!/bin/bash

#SBATCH -p cloud
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mail-user=emorgan@nd.edu
#SBATCH -t 48:0:00
#SBATCH -J TXT2ENT
#SBATCH -o ./log/txt2ent-output.txt
#SBATCH -e ./log/txt2ent-error.txt

#SBATCH --mail-type=ALL

cd /export/cord
mkdir -p ./cord/ent; find ./cord/txt -name '*.txt' | sort | parallel ./bin/txt2ent-cord.sh
