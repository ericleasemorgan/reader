#!/usr/bin/env python

# search.py - query a full text index

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# August 26, 2022 - first cut; while waiting for my flight to Lyon


# configure
TEMPLATE = "SELECT * FROM indx WHERE indx MATCH '##QUERY##' ORDER BY RANK;"
DATABASE = './etc/cord.db'

# require
import sqlite3
import pandas as pd
import sys

# get input
if len( sys.argv ) != 3 : sys.exit( 'Usage: ' + sys.argv[ 0 ] + " <query> <json|csv>" )
query  = sys.argv[ 1 ]
format = sys.argv[ 2 ]

# initialize, create sql, and search
connection = sqlite3.connect( DATABASE )
sql        = TEMPLATE.replace( '##QUERY##', query )
results    = pd.read_sql_query( sql, connection )

# branch according to format
if   format == 'json' : print( results.to_json( orient='records' ) )
elif format == 'csv'  : print( results.to_csv( index=False ) )
else                  : sys.exit( 'Usage: ' + sys.argv[ 0 ] + " <query> <json|csv>" )

# done
exit()

