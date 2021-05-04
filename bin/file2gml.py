#!/usr/bin/env python

# configure
OUTPUT = '/tmp/graph.gml'

# require
import networkx as nx
import sys
import os

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <file>\n" )
	quit()

# get input
file = sys.argv[ 1 ]

# initialize
G = nx.DiGraph()

# slurp up the data
with open ( file ) as handle : records = handle.readlines()

# process each record
for record in records :
	
	# parse
	record = record.strip()
	fields = record.split( "\t" )
		
	# update
	G.add_edge( fields[ 0 ],  fields[ 1 ] )

# save, output, clean-up and done; convoluted
nx.write_gml( G, OUTPUT )
with open ( OUTPUT ) as handle : print( handle.read() )
os.remove( OUTPUT )
exit
