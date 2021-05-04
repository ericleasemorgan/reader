#!/usr/bin/env bash

# query.sh  - given a simple SQL query, output simple result


# configure
DB='./etc/reader.db'

# sanity check
if [[ -z $1 ]]; then

	echo "Usage: $0 <sql>" >&2
	exit
	
fi

# get input
SQL=$1

# query and done
printf "$SQL" | sqlite3 $DB 
exit
