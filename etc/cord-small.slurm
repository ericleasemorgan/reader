#!/bin/bash

#SBATCH -p cloud
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mail-user=emorgan@nd.edu
#SBATCH -t 48:0:00
#SBATCH -J cord-##SIZE##
#SBATCH -o standard-output.txt
#SBATCH -e standard-error.txt

#SBATCH --mail-type=ALL

cd /export/reader/carrels/##NAME##
/export/reader/bin/cord2carrel-map.sh
