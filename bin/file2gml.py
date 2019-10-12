#!/usr/bin/env python

# configure
FILE   = './man.tsv';
OUTPUT = '/tmp/graph.gml'

# require
import networkx as nx
import sys
import os

# initialize
G = nx.DiGraph()

# slurp up the data
with open ( FILE ) as handle : records = handle.readlines()

# process each record
for record in records :
	
	# parse
	record = record.strip()
	fields = record.split( "\t" )
	node01 = fields[ 0 ]
	node02 = fields[ 1 ]
	
	# update
	G.add_edge( node01,  node02 )

# save, output, clean-up and done; convoluted
nx.write_gml( G, OUTPUT )
with open ( OUTPUT ) as handle : print( handle.read() )
os.remove( OUTPUT )
exit
