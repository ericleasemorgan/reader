#!/usr/bin/env bash

# queue2carrels.sh - find queued processes and do the work accordingly

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# August 1, 2018 - first investigations and in Lake Geneva after HathiTrust workshop in Milwaukee; "Happy birthday, Barb!"
# August 2, 2018 - back at home and getting closer; works, but only one at a time


# configure
FILE2CARREL='./bin/file2carrel.sh'
URLS2CARREL='./bin/urls2carrel.sh'
ZOTERO2CARREL='./bin/zotero2carrel.sh'
URL2CARREL='./bin/url2carrel.sh'
DB='./etc/library.db'
TMP='./tmp'

# get the number of queued items
COUNT=$( echo "SELECT COUNT(id) FROM acquisitions WHERE status='queued';" | sqlite3 -separator $'\t' $DB )

# if some exist, then get them
if [[ $COUNT > 0 ]]; then

	# get a list of the queued items
	QUEUE=$( echo "SELECT * FROM acquisitions WHERE status='queued';" | sqlite3 -separator $'\t' $DB )

	# process each found record in the queue
	while read -r RECORD; do
	
		# re-initialize
		IFS=$'\t'
	
		# parse
		FEILDS=($RECORD)
		ID=${FEILDS[0]}
		CREATED=${FEILDS[1]}
		PROCESS=${FEILDS[2]}
		INPUT=${FEILDS[3]}
		KEY=${FEILDS[4]}
		EMAIL=${FEILDS[5]}
		IP=${FEILDS[6]}
		UPDATED=${FEILDS[7]}
		STATUS=${FEILDS[8]}
		NOTE=${FEILDS[9]}

		# check for valid/known processes
		if [[ $PROCESS = "file2carrel" || $PROCESS = "urls2carrel" || $PROCESS = "zotero2carrel" ]]; then
			
			# make sure input exists
			if [[ ! -f "$TMP/$INPUT" ]]; then

				# error; file not found
				NOTE="Error: input not found."
				echo "$NOTE" >&2
				echo "UPDATE acquisitions SET 'date_updated'=datetime(), 'status'='failed', 'note'='$NOTE' WHERE id='$ID';" | sqlite3 $DB 

			# success
			else

				# build the command
				if   [[ $PROCESS = "file2carrel"   ]]; then COMMAND=$FILE2CARREL
				elif [[ $PROCESS = "urls2carrel"   ]]; then COMMAND=$URLS2CARREL
				elif [[ $PROCESS = "zotero2carrel" ]]; then COMMAND=$ZOTERO2CARREL
				fi
				
				# do the work and update the queue
				echo "UPDATE acquisitions SET 'date_updated'=datetime(), 'status'='running', 'note'='Still, so far, so good.' WHERE id='$ID';" | sqlite3 $DB 
				$COMMAND $INPUT $EMAIL

			fi
				
		# check for other known processes
		elif [[ $PROCESS = "url2carrel" ]]; then
	
			# make sure input exists
			if [[ -z "$INPUT" ]]; then

				# error; no input
				NOTE="Error: input has no value."
				echo "$NOTE" >&2
				echo "UPDATE acquisitions SET 'date_updated'=datetime(), 'status'='failed', 'note'='$NOTE' WHERE id='$ID';" | sqlite3 $DB 

			# success
			else

				# do the work and update the queue
				echo "UPDATE acquisitions SET 'date_updated'=datetime(), 'status'='running', 'note'='Still, so far, so good.' WHERE id='$ID';" | sqlite3 $DB 
				$URL2CARREL $INPUT $EMAIL

			fi

		# unknown process; update database
		else 
	
			NOTE="Error: Unknown process ($PROCESS)."
			echo "$NOTE" >&2
			echo "UPDATE acquisitions SET 'date_updated'=datetime(), 'status'='failed', 'note'='$NOTE' WHERE id='$ID';" | sqlite3 $DB 
		
		fi
	
	done <<< "$QUEUE"

# zero queued records
else

	echo "The queue is empty; there is no work to do. Hooray!?" >&2

fi

