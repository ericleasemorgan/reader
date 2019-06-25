#!/export/python/bin/python

# concordance.cgi - keyword-in-context index

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, distributed under a GNU Public License

# April 23, 2018 - first investigations; 
# August 7, 2018 - started migrating Distant Reader


# configure
FILE  = '../txt/##ID##.txt';
WIDTH = 80

# require
from nltk        import *
from nltk.corpus import stopwords
import cgi
import sqlite3

import cgitb
cgitb.enable()
#print( 'Content-Type: text/html\n' )

# initialize
input = cgi.FieldStorage()

# check for input; build default page
if "id" not in input or "word" not in input :

	print( 'Content-Type: text/html\n' )
	print ( '''<html><head><title>Distant Reader - Simple concordance</title><base href="http://carrels.distantreader.org/library/homer/" />
<meta name="viewport" content="width=device-width, initial-scale=1.0"><link rel="stylesheet" href="./etc/style.css"></head><body><div class="header"><h1>Distant Reader - Simple concordance</h1></div><div class="col-3 col-m-3 menu"><ul><li><a href="./about.html">Home</a></li><li><a href="/reader/about/">About</a></li></ul></div><div class="col-9 col-m-9"><p>Given a Distant Reader identifier and an word, this form returns a list of lines from the given text containing the word -- a keyword in context search result.</p><form method="GET" action="./cgi-bin/concordance.cgi">Identifier: <input type="text" name="id" value="homer-iliad-850_16" /><br />Word: <input type="text" name="word" value="love"/><br /><input type="submit" value="List lines" /></form><div class="footer"><p style="text-align: right">Eric Lease Morgan &amp; Team Distant Reader<br />August 7, 2018</p></div></div></body></html>''' )

# process the input
else :
	
	# get input / initialize
	id   = input[ 'id' ].value
	word = input[ 'word' ].value
	
	# compute the name of the file to query
	file = FILE.replace( '##ID##', id )	

	# open and read the desired file
	handle  = open( file, 'r', encoding='utf-8' )
	index   = ConcordanceIndex( word_tokenize( handle.read() ), key = lambda s:s.lower() )
	offsets = index.offsets( word )

	# initialize output
	print( 'Content-Type: text/plain; charset=utf-8\n' )

	# process each found item
	if offsets :

		half    = ( WIDTH - len( word ) - 2) // 2
		lines   = []
		
		for i in offsets :
	
			token = index._tokens[ i ]
			left  = index._tokens[ i - WIDTH : i ]
			right = index._tokens[ i + 1 : i + WIDTH ]
			lines.append( ' '.join([' '.join( left )[ -half : ], token, ' '.join( right )[ : half ] ] ) )

		for i, line in enumerate( lines ) : print( "% 4d) %s" % ( i + 1, line ) )
	
	else : print( "%s not found." % ( word ) )
		
# done
quit()


