#!/bin/bash

# template.slurm - a SLURM template; a tautology 

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# June 2, 2020 - first documentation
# June 3, 2020 - added partition option


# sbatch configurations
#SBATCH -p ##PARTITION##
#SBATCH -N 1
#SBATCH -n ##CORES##
#SBATCH -t 96:0:00
#SBATCH -J ##NAME##
#SBATCH -o standard-output.txt
#SBATCH -e standard-error.txt
#SBATCH --mail-user=##EMAIL##
#SBATCH --mail-type=ALL


# give a status report
#echo -e "\nThe creation of your carrel, ##NAME##, has started. See http://cord.distantreader.org/carrels/##NAME##/  --ELM\n" | mail -s "[PROJECTCORD] ##NAME## started" -r emorgan@nd.edu -c emorgan@nd.edu ##EMAIL##

# make sane
cd /export/reader/carrels/##NAME##

# assume this carrel is to be re-created; re-initialize
rm -rf adr                 &
rm -rf bib                 &
rm -rf css                 &
rm -rf ent                 &
rm -rf etc                 &
rm -rf figures             &
rm -rf htm                 &
rm -rf index.htm           &
rm -rf js                  &
rm -rf LICENSE             &
rm -rf MANIFEST.htm        &
rm -rf pos                 &
rm -rf README              &
rm -rf study-carrel.zip    &
rm -rf tsv                 &
rm -rf txt                 &
rm -rf urls                &
rm -rf wrd                 &
rm -rf tmp                 &
wait

# do the work
/export/reader/bin/cord2carrel.sh

# give another status report and done
#echo -e "\nYour carrel, ##NAME##, has been created. See http://cord.distantreader.org/carrels/##NAME##/  --ELM\n" | mail -s "[PROJECTCORD] ##NAME## created" -r emorgan@nd.edu -c emorgan@nd.edu ##EMAIL##
exit
