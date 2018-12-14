#!/usr/bin/env python

# file2txt.py - given a file name, output plain text; a front-end to tika.jar

# require
from tika import parser
import sys
import tika

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <file>\n" )
	exit()

# initialize
tika.initVM()
file = sys.argv[ 1 ]

# do the work, output, and done
parsed = parser.from_file( file )
print( parsed[ "content" ] )
exit()
