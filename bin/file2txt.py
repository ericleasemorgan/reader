#!/usr/bin/env python

# file2txt.py - given a file name, output plain text; a front-end to tika.jar

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# February 2, 2019 - first document; written a while ago; "Happy Birthday, Mary!"


# require
import sys
import os

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <file>\n" )
	exit()

from tika import parser
import tika

# initialize
tika.initVM()
file = sys.argv[ 1 ]

# do the work, output, and done
parsed = parser.from_file( file )
print( parsed[ "content" ] )
exit()

