#!/bin/bash

#SBATCH -p cloud
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mail-user=emorgan@nd.edu
#SBATCH -t 48:0:00
#SBATCH -J ##NAME##
#SBATCH -o standard-output.txt
#SBATCH -e standard-error.txt

#SBATCH --mail-type=ALL

cd /home/emorgan/sandbox/carrels/##NAME##
/export/reader/bin/cord2carrel.sh
