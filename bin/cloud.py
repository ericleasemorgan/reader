#!/usr/bin/env python

# cloud.py - given a corpus name, read a data file and generate a word cloud

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# November 12, 2018 - first documentation
# May      29, 2019 - reworking for Distant Reader


# configure
HEIGHT = 960
WIDTH  = 1280

# require
import sys
from wordcloud import WordCloud

# sanity check
if len( sys.argv ) != 4 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <input file> <color> <output file>\n" )
	exit()

# initialize
items  = {}
input  = sys.argv[ 1 ]
color  = sys.argv[ 2 ]
output = sys.argv[ 3 ]

# open the input
with open( input ) as I :
	
	# process each line
	for line in I :
		
		# parse and build a dictionary of content
		record        = line.rstrip().split( '\t' )
		item          = record[ 0 ]
		frequency     = float( record[ 1 ] )
		items[ item ] = frequency

# build the cloud, save it, and done
wordcloud = WordCloud( width = WIDTH, height = HEIGHT, background_color = color )
wordcloud.generate_from_frequencies( items ).to_file( output )
exit()

