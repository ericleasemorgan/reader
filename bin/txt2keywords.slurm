#!/bin/bash

#SBATCH -p big-cloud
#SBATCH --mail-user=emorgan@nd.edu
#SBATCH -t 48:0:00
#SBATCH -J TXT2KEYWORDS
#SBATCH -o ./log/txt2keywords-output.txt
#SBATCH -e ./log/txt2keywords-error.txt

#SBATCH --mail-type=ALL

cd /export/cord
mkdir -p ./wrd; find ./txt -name '*.txt' | sort | parallel ./bin/txt2keywords.sh
