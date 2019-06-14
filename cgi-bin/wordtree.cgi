#!/usr/local/anaconda/bin/python

# wordtree.cgi - given a word, generated a concordance-like visualization

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, distributed under a GNU Public License

# August 11, 2018 - first investigations; still have encoding problems, arg!


# configure
FILE     = '../txt/##ID##.txt';
WIDTH    = 240
TEMPLATE = '''<html><!-- https://developers.google.com/chart/interactive/docs/gallery/wordtree --><head><script type='text/javascript' src='https://www.gstatic.com/charts/loader.js'></script><script type='text/javascript'> google.charts.load('current', {packages:['wordtree']}); google.charts.setOnLoadCallback(drawChart); function drawChart() { var data = google.visualization.arrayToDataTable( [ ['Phrases'], ##DATA##, ] ); var options = { wordtree: { format: 'implicit', word: '##WORD##', type: 'double' } }; var chart = new google.visualization.WordTree(document.getElementById('wordtree_basic')); chart.draw(data, options); }</script></head><body><div id='wordtree_basic' style='width: 900px; height: 500px;'></div></body></html>'''

# require
from nltk        import *
from nltk.corpus import stopwords
import cgi
import cgitb

# initialize I/O
cgitb.enable()
print( 'Content-Type: text/html\n' )
input = cgi.FieldStorage()

# check for input; build default page
if "id" not in input or "word" not in input :

	print ( '''<html><head><title>Distant Reader - Word tree</title><meta name="viewport" content="width=device-width, initial-scale=1.0"><base href='http://dh.crc.nd.edu/sandbox/reader/hackaton/code4lib-journal/'/><link rel="stylesheet" href="./etc/style.css"></head><body><div class="header"><h1>Distant Reader - Word tree</h1></div><div class="col-3 col-m-3 menu"><ul><li><a href="/reader/home.html">Home</a></li><li><a href="/reader/about/">About</a></li></ul></div><div class="col-9 col-m-9"><p>Given a Distant Reader identifier and a word, this form returns a concordance-like visualization.</p><form method="GET" action="./cgi-bin/wordtree.cgi">Identifier: <input type="text" name="id" value="ZebMBln" /><br />Word: <input type="text" name="word" value="love"/><br /><input type="submit" value="Word tree" /></form><div class="footer"><p style="text-align: right">Eric Lease Morgan &amp; Team Distant Reader<br />August 11, 2018</p></div></div></body></html>''' )

# process the input
else :
	
	# get input / initialize
	id   = input[ 'id' ].value
	word = input[ 'word' ].value
	
	# compute the name of the database to query
	file = FILE.replace( '##ID##', id )	

	# open and read the desired file
	handle  = open( file, 'r', encoding='utf-8' )
	index   = ConcordanceIndex( word_tokenize( handle.read() ), key = lambda s:s.lower() )
	offsets = index.offsets( word )

	# process each found item
	if offsets :

		half  = ( WIDTH - len( word ) - 2) // 2
		lines = []
	
		# process each found occurence
		for i in offsets :

			token = index._tokens[ i ]
			left  = index._tokens[ i - WIDTH : i ]
			right = index._tokens[ i + 1 : i + WIDTH ]
			lines.append( ' '.join([' '.join( left )[ -half : ], token, ' '.join( right )[ : half ] ] ) )
	
		# create the data to for the html
		data = ','.join( "['" + line + "']" for line in lines )	
	
		# build the html and output
		html = TEMPLATE
		html = html.replace( '##WORD##', word )	
		html = html.replace( '##DATA##', data )	
		print ( html.encode( 'utf-8' ) )
		
	else : print( "%s not found." % ( word ) )
		
# done
quit()


