#!/usr/local/anaconda/bin/python

# posnet.cgi - list the frequency of selected parts-of-speech and named-entities

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, distributed under a GNU Public License

# June   13, 2018 - first investigations; 
# August 7,  2018 - moving to Distant Reader; still having problems with encoding issues
# August 12, 2018 - added word cloud as output


# configure
FILE     = '../tmp/cloud.jpg'
WIDTH    = 640
HEIGHT   = 400
COLOR    = 'white'
DATABASE = '../carrels/##ID##/etc/reader.db';
QUERIES  = { 'pos'            : "SELECT COUNT( pos )    AS f, pos     FROM pos                               GROUP BY pos    ORDER BY f DESC;",
            'nouns'           : "SELECT COUNT( token )  AS f, token   FROM pos      WHERE pos LIKE 'N%'      GROUP BY token  ORDER BY f DESC;",
            'nounslemma'      : "SELECT COUNT( lemma )  AS f, lemma   FROM pos      WHERE pos LIKE 'N%'      GROUP BY lemma  ORDER BY f DESC;",
            'pronouns'        : "SELECT COUNT( token )  AS f, token   FROM pos      WHERE pos LIKE 'PR%'     GROUP BY token  ORDER BY f DESC;",
            'pronounslemma'   : "SELECT COUNT( lemma )  AS f, lemma   FROM pos      WHERE pos LIKE 'PR%'     GROUP BY lemma  ORDER BY f DESC;",
            'verbs'           : "SELECT COUNT( token )  AS f, token   FROM pos      WHERE pos LIKE 'V%'      GROUP BY token  ORDER BY f DESC;",
            'verbslemma'      : "SELECT COUNT( lemma )  AS f, lemma   FROM pos      WHERE pos LIKE 'V%'      GROUP BY lemma  ORDER BY f DESC;",
            'adjectives'      : "SELECT COUNT( token )  AS f, token   FROM pos      WHERE pos LIKE 'J%'      GROUP BY token  ORDER BY f DESC;",
            'adjectiveslemma' : "SELECT COUNT( lemma )  AS f, lemma   FROM pos      WHERE pos LIKE 'J%'      GROUP BY lemma  ORDER BY f DESC;",
            'adverbs'         : "SELECT COUNT( token )  AS f, token   FROM pos      WHERE pos LIKE 'RB%'     GROUP BY token  ORDER BY f DESC;",
            'adverbslemma'    : "SELECT COUNT( lemma )  AS f, lemma   FROM pos      WHERE pos LIKE 'RB%'     GROUP BY lemma  ORDER BY f DESC;",
            'entities'        : "SELECT COUNT( type )   AS f, type    FROM ent                          GROUP BY type   ORDER BY f DESC;",
            'people'          : "SELECT COUNT( entity ) AS f, entity  FROM ent WHERE type='PERSON'      GROUP BY entity ORDER BY f DESC;",
            'religions'       : "SELECT COUNT( entity ) AS f, entity  FROM ent WHERE type='NORP'        GROUP BY entity ORDER BY f DESC;",
            'worksofart'      : "SELECT COUNT( entity ) AS f, entity  FROM ent WHERE type='WORK_OF_ART' GROUP BY entity ORDER BY f DESC;",
            'languages'       : "SELECT COUNT( entity ) AS f, entity  FROM ent WHERE type='LANGUAGE'    GROUP BY entity ORDER BY f DESC;",
            'organizations'   : "SELECT COUNT( entity ) AS f, entity  FROM ent WHERE type='ORG'         GROUP BY entity ORDER BY f DESC;",
            'places'          : "SELECT COUNT( entity ) AS f, entity  FROM ent WHERE type='GPE' or type='LOC' GROUP BY entity ORDER BY f DESC;" }

# require
import cgi
import sqlite3
from wordcloud import WordCloud

import cgitb
cgitb.enable()
#print( 'Content-Type: text/html\n' )

# initialize
input = cgi.FieldStorage()

# check for input; build default page
if ( "id" not in input or 'type' not in input ) :

	print( 'Content-Type: text/html\n' )
	print ( '''<html><head><title>Distant Reader - Parts-of-speech &amp; named-entities</title><meta name="viewport" content="width=device-width, initial-scale=1.0"><link rel="stylesheet" href="/reader/etc/style.css"></head><body><div class="header"><h1>Distant Reader - Parts-of-speech &amp; named-entities</h1></div><div class="col-3 col-m-3 menu"><ul><li><a href="/reader/home.html">Home</a></li><li><a href="/reader/about/">About</a></li></ul></div><div class="col-9 col-m-9"><p>Use this page to list the frequency of selected parts-of-speech and named entities existing in a study carrel. This is is useful for gauging what &amp; how things are discussed.</p><form method="GET" action="/reader/cgi-bin/posent.cgi">Identifier: <input type="text" name="id" value="ZebMBln" /><br />Selection: <select name='type'><option value='pos'>types of parts-of-speech</option><option value='nouns'>nouns</option><option value='nounslemma'>lemmatized nouns</option><option value='pronouns'>pronouns</option><option value='pronounslemma'>lemmatized pronouns</option><option value='verbs'>verbs</option><option value='verbslemma'>lemmatized verbs</option><option value='adjectives'>adjectives</option><option value='adjectiveslemma'>lemmatized adjectives</option><option value='adverbs'>adverbs</option><option value='adverbslemma'>lemmatized adverbs</option><option value='entities'>types of named-entities</option><option value='people'>people</option><option value='places'>places</option><option value='organizations'>organizations</option><option value='religions'>religions</option><option value='worksofart'>works of art</option><option value='languages'>languages</option></select></br>Output: <input name='output' type='radio' value='image' checked='checked'> wordcloud image</input> <input name='output' type='radio' value='table'> tab-delimited text</input></br><input type="submit" value="Show frequencies" /></form><div class="footer"><p style="text-align: right">Eric Lease Morgan &amp; Team Distant Reader<br />August 7, 2018</p></div></div></body></html>''' )

# process the input
else :
	
	# get input / initialize
	id     = input[ 'id' ].value
	type   = input[ 'type' ].value
	output = input[ 'output' ].value

	# compute name of database
	database = DATABASE.replace( '##ID##', id )	

	# query the sub-database
	connection = sqlite3.connect( database )
	cursor     = connection.cursor()

	# branch according to desired output
	if ( output == 'image' ) :
	
		items      = {}
		for row in cursor.execute( QUERIES[ type ] ) :
		
			frequency     = row[ 0 ]
			item          = row[ 1 ]
			items[ item ] = frequency

		# initialize word cloud, build it, and save it
		wordcloud = WordCloud( width = WIDTH, height = HEIGHT, background_color = COLOR )
		wordcloud.generate_from_frequencies( items ).to_file( FILE )

		print( 'Content-Type: text/html\n' )
		print( '''<html><head><title>Distant Reader - Simple counts &amp; tabulations</title><meta name="viewport" content="width=device-width, initial-scale=1.0"><link rel="stylesheet" href="/english/etc/style.css"></head><body><div class="header"><h1>Distant Reader - Simple counts &amp; tabulations</h1></div><div class="col-3 col-m-3 menu"><ul><li><a href="/reader/home.html">Home</a></li><li><a href="/reader/about/">About</a></li></ul></div><div class="col-9 col-m-9"><p><img src='http://cds.crc.nd.edu/reader/tmp/cloud.jpg'/></p><div class="footer"><p style="text-align: right">Eric Lease Morgan &amp; Team Distant Reader<br />August 7, 2018</p></div></div></body></html>''' )

	elif ( output == 'table' ) :

		# initialize output
		print( 'Content-Type: text/plain\n' )
		print( 'frequency\titem' )

		# query the sub-database
		connection = sqlite3.connect( database )
		cursor     = connection.cursor()
		for row in cursor.execute( QUERIES[ type ] ) :
		
			# parse and output
			frequency = str( row[ 0 ] )
			item      = str( row[ 1 ] )
			print( "\t".join( ( frequency, item ) ) )


	else :
	
		# initialize output
		print( 'Content-Type: text/plain\n' )
		print( "Unknown value for 'output'. Call Eric." )

# done
quit()


