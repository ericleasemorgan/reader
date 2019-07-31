#!/usr/bin/env python

# about.py - summarize the contents of a study carrel

# Eric Lease Morgan <emorgan@nd.ed>
# (c) University of Notre Dame; distributed under GNU Public License

# June 11, 2019 - first documentation
# July 21, 2019 - switching to Python
# July 30, 2019 - hacking at PEARC '19


# configure
CLOUD      = '/export/reader/bin/cloud.py'
CLOUDCOUNT = 150
CORPUS     = './etc/reader.txt'
COUNT      = 50
DATABASE   = './etc/reader.db'
DIRECTORY  = './txt'
NGRAMS     = '/export/reader/bin/ngrams.pl'
PLOTFLESCH = '/export/reader/bin/plot-flesch.sh'
PLOTSIZES  = '/export/reader/bin/plot-sizes.sh'
TOPICMODEL = '/export/reader/bin/topic-model.py'
TEMPLATE   = '/export/reader/etc/about.htm'

# require
from sqlalchemy import create_engine
import pandas as pd
import subprocess
import sys
import os

# define
def model2dataframe( model ) :
	'''Transform the output of topic-model.py into a data frame'''
	
	# remove bogus carriage returns
	model = model.rstrip()
	
	# create a list of dictionaries
	rows = []
	for topic in model.split( '\n' ) :
		fields = topic.split( '\t' )
		row = { 'id': fields[ 0 ], 'score':fields[ 1 ], 'words':fields[ 2 ], 'files':fields[ 3 ] }
		rows.append( row )
	
	# create and format the dataframe
	df = pd.DataFrame( rows )
	df = df[ [ 'id', 'score', 'words', 'files' ] ]
	df = df.set_index('id')
	
	# done
	return( df )


def addBibliographics( df, engine ) :
	'''Update a data frame with columns of bibliographic data'''
	
	# initialize
	authors = []
	titles  = []
	dates   = []

	# process each row in the given dataframe
	for index, row in df.iterrows() :
		
		# re-initialize
		author = []
		title  = []
		date   = []
		
		# process each file
		for id in row[ 'files'].split( ';' ) :
			
			# parse
			id, extention = os.path.splitext( id )
			id            = os.path.basename( id )
			
			# search, and conditionally update
			result = pd.read_sql_query( "SELECT author, title, date FROM bib where id is '" + id + "'", engine )
			
			# update with empty values
			if ( result.empty ) :
			
				author.append( '' )
				title.append( '' )
				date.append( '' )
				
			# update with found values
			else :
			
				author.append( result.iloc[ 0, 0 ] )
				title.append( result.iloc[ 0, 1 ] )
				date.append( result.iloc[ 0, 2 ] )
						
		# update
		authors.append( '|'.join( author ) )
		titles.append( '|'.join( title ) )
		dates.append( '|'.join( date ) )

	# add bibliographic columns to the dataframe and done
	df['authors'] = authors 
	df['titles']  = titles 
	df['dates']   = dates 
	return( df )


def readModel( directory, engine, t, d, f ) :
	'''Given a directory, database engine, number of topics, number of dimensions, and number of files, return topics and bibliographics'''
	
	# model the data, stuff the results into a dataframe, and add bibliographics
	model = subprocess.check_output( [ TOPICMODEL, directory, str( t ), str( d ) ] ).decode( 'utf-8' )
	df    = addBibliographics( model2dataframe( model ), engine )
	
	# initialize
	words  = []
	files  = []
	titles = []
	
	# process each topic in the DataFrame
	for index, row in df.iterrows() :

		words.append( row[ 'words' ] )
		
		items = row[ 'files' ]
		items = items.split( ';' )
		files.append( items[ 0:f ] )
		
		items = row[ 'titles' ]
		items = items.split( '|' )
		titles.append( items[ 0:f ] )

	# done
	return words, files, titles
	
	
# initialize
engine = create_engine( 'sqlite:///' + DATABASE )

# number of items
numberOfItems = pd.read_sql_query( 'SELECT COUNT( id ) FROM bib', engine )
numberOfItems = f'{numberOfItems.iloc[ 0, 0 ]:,}'

# sum of words
sumOfWords = pd.read_sql_query( 'SELECT SUM( words ) FROM bib', engine )
sumOfWords = f'{sumOfWords.iloc[ 0, 0 ]:,}'

# average size in words
averageSizeInWords = pd.read_sql_query( 'SELECT AVG( words ) FROM bib', engine )
averageSizeInWords = f'{int( averageSizeInWords.iloc[ 0, 0 ] ):,}'

# average readability score
averageReadabilityScore = pd.read_sql_query( 'SELECT AVG( flesch ) FROM bib', engine )
averageReadabilityScore = int( averageReadabilityScore.iloc[ 0, 0 ] )

# plot sizes and readability
if( not os.path.exists( './figures/sizes-histogram.png' ) )  : subprocess.run( [ PLOTSIZES,  'histogram', './figures/sizes-histogram.png'  ] ) 
if( not os.path.exists( './figures/sizes-boxplot.png' ) )    : subprocess.run( [ PLOTSIZES,  'boxplot',   './figures/sizes-boxplot.png'    ] ) 
if( not os.path.exists( './figures/flesch-histogram.png' ) ) : subprocess.run( [ PLOTFLESCH, 'histogram', './figures/flesch-histogram.png' ] ) 
if( not os.path.exists( './figures/flesch-boxplot.png' ) )   : subprocess.run( [ PLOTFLESCH, 'boxplot',   './figures/flesch-boxplot.png'   ] ) 

# nouns
nouns = pd.read_sql_query( "select lower(token) as 'noun', count(lower(token)) as frequency from pos where pos is 'NN' or pos is 'NNS' group by lower(token) order by frequency desc", engine )
if ( not os.path.exists( './tsv/nouns.tsv' ) ) : nouns.to_csv( './tsv/nouns.tsv', sep='\t', columns=[ 'noun', 'frequency' ], index=False )
if ( not os.path.exists( './figures/nouns.png' ) ) :
	data = nouns[ 0:CLOUDCOUNT ]
	data.to_csv( './tmp/nouns.tsv', columns=[ 'noun', 'frequency' ], header=False, sep='\t', index=False )
	subprocess.run( [ CLOUD, './tmp/nouns.tsv', 'white', './figures/nouns.png' ] )
nouns = nouns[ 'noun' ].iloc[ : COUNT ].tolist()

# verbs
verbs = pd.read_sql_query( "select lower(token) as 'verb', count(lower(token)) as frequency from pos where pos like 'VB%%' group by lower(token) order by frequency desc", engine )
if ( not os.path.exists( './tsv/verbs.tsv' ) ) : verbs.to_csv( './tsv/verbs.tsv', sep='\t', columns=[ 'verb', 'frequency' ], index=False )
if ( not os.path.exists( './figures/verbs.png' ) ) :
	data = verbs[ 0:CLOUDCOUNT ]
	data.to_csv( './tmp/verbs.tsv', columns=[ 'verb', 'frequency' ], header=False, sep='\t', index=False )
	subprocess.run( [ CLOUD, './tmp/verbs.tsv', 'white', './figures/verbs.png' ] )
verbs = verbs[ 'verb' ].iloc[ : COUNT ].tolist()

# adjectives
adjectives = pd.read_sql_query( "select lower(token) as 'adjective', count(lower(token)) as frequency from pos where pos like 'J%%' group by lower(token) order by frequency desc", engine )
if ( not os.path.exists( './tsv/adjectives.tsv' ) ) : adjectives.to_csv( './tsv/adjectives.tsv', sep='\t', columns=[ 'adjective', 'frequency' ], index=False )
if ( not os.path.exists( './figures/adjectives.png' ) ) :
	data = adjectives[ 0:CLOUDCOUNT ]
	data.to_csv( './tmp/adjectives.tsv', columns=[ 'adjective', 'frequency' ], header=False, sep='\t', index=False )
	subprocess.run( [ CLOUD, './tmp/adjectives.tsv', 'white', './figures/adjectives.png' ] )
adjectives = adjectives[ 'adjective' ].iloc[ : COUNT ].tolist()

# adverbs
adverbs = pd.read_sql_query( "select lower(token) as 'adverb', count(lower(token)) as frequency from pos where pos like 'R%%' group by lower(token) order by frequency desc", engine )
if ( not os.path.exists( './tsv/adverbs.tsv' ) ) : adverbs.to_csv( './tsv/adverbs.tsv', sep='\t', columns=[ 'adverb', 'frequency' ], index=False )
if ( not os.path.exists( './figures/adverbs.png' ) ) :
	data = adverbs[ 0:CLOUDCOUNT ]
	data.to_csv( './tmp/adverbs.tsv', columns=[ 'adverb', 'frequency' ], header=False, sep='\t', index=False )
	subprocess.run( [ CLOUD, './tmp/adverbs.tsv', 'white', './figures/adverbs.png' ] )
adverbs = adverbs[ 'adverb' ].iloc[ : COUNT ].tolist()

# pronouns
pronouns = pd.read_sql_query( "select lower(token) as 'pronoun', count(lower(token)) as frequency from pos where pos like 'PR%%' group by lower(token) order by frequency desc", engine )
if ( not os.path.exists( './tsv/pronouns.tsv' ) ) : pronouns.to_csv( './tsv/pronouns.tsv', sep='\t', columns=[ 'pronoun', 'frequency' ], index=False )
if ( not os.path.exists( './figures/pronouns.png' ) ) :
	data = pronouns[ 0:CLOUDCOUNT ]
	data.to_csv( './tmp/pronouns.tsv', columns=[ 'pronoun', 'frequency' ], header=False, sep='\t', index=False )
	subprocess.run( [ CLOUD, './tmp/pronouns.tsv', 'white', './figures/pronouns.png' ] )
pronouns = pronouns[ 'pronoun' ].iloc[ : COUNT ].tolist()

# proper nouns
properNouns = pd.read_sql_query( "select lower(token) as 'proper', count(lower(token)) as frequency from pos where pos like 'NNP%%' group by lower(token) order by frequency desc", engine )
if ( not os.path.exists( './tsv/proper-nouns.tsv' ) ) : properNouns.to_csv( './tsv/proper-nouns.tsv', sep='\t', columns=[ 'proper', 'frequency' ], index=False )
if ( not os.path.exists( './figures/proper-nouns.png' ) ) :
	data = properNouns[ 0:CLOUDCOUNT ]
	data.to_csv( './tmp/proper-nouns.tsv', columns=[ 'proper', 'frequency' ], header=False, sep='\t', index=False )
	subprocess.run( [ CLOUD, './tmp/proper-nouns.tsv', 'white', './figures/proper-nouns.png' ] )
properNouns = properNouns[ 'proper' ].iloc[ : COUNT ].tolist()

# keywords
keywords = pd.read_sql_query( "select lower( keyword ) as 'keyword', count( keyword ) as frequency from wrd group by lower( keyword ) order by frequency desc", engine )
if ( not os.path.exists( './tsv/keywords.tsv' ) ) : keywords.to_csv( './tsv/keywords.tsv', sep='\t', columns=[ 'keyword', 'frequency' ], index=False )
if ( not os.path.exists( './figures/kekeywordsywords.png' ) ) :
	data = keywords[ 0:CLOUDCOUNT ]
	data.to_csv( './tmp/keywords.tsv', columns=[ 'keyword', 'frequency' ], header=False, sep='\t', index=False )
	subprocess.run( [ CLOUD, './tmp/keywords.tsv', 'white', './figures/keywords.png' ] )
keywords = keywords[ 'keyword' ].iloc[ : COUNT ].tolist()

# grammers; noun-verb
if ( not os.path.exists( './tsv/noun-verb.tsv' ) ) :
	nounVerb = pd.read_sql_query( "SELECT ( LOWER( t.token || ' ' || c.token )) AS sentence, COUNT( LOWER( t.token || ' ' || c.token ) ) AS frequency FROM pos AS t JOIN pos AS c ON c.tid=t.tid+1 AND c.sid=t.sid AND c.id=t.id WHERE t.lemma IN (select lemma from pos where pos like 'N%%' or pos like 'P%%' group by lemma order by count(lemma) desc) AND c.lemma in (select lemma from pos where pos like 'V%%' group by lemma order by count(lemma) desc) GROUP BY sentence ORDER BY frequency DESC, ( LOWER( t.token || ' ' || c.token ) )", engine )
	nounVerb[ [ 'noun', 'verb' ] ] = nounVerb.sentence.str.split( ' ', expand=True )
	nounVerb.to_csv( './tsv/noun-verb.tsv', columns=[ 'noun', 'verb', 'frequency' ], sep='\t', index=False )

# adjective-noun
if ( not os.path.exists( './tsv/verbs.tsv' ) ) :
	adjectiveNoun = pd.read_sql_query( "SELECT ( LOWER( t.token || ' ' || c.token )) AS sentence, COUNT( LOWER( t.token || ' ' || c.token ) ) AS frequency FROM pos AS t JOIN pos AS c ON c.tid=t.tid+1 AND c.sid=t.sid AND c.id=t.id WHERE t.lemma IN (select lemma from pos where pos like 'J%%' group by lemma order by count(lemma) desc limit 30) AND c.lemma in (select lemma from pos where pos like 'N%%' group by lemma order by count(lemma) desc limit 30) GROUP BY sentence ORDER BY frequency DESC, ( LOWER( t.token || ' ' || c.token ) )", engine )
	adjectiveNoun[ [ 'adjective', 'noun' ] ] = adjectiveNoun.sentence.str.split( ' ', expand=True )
	adjectiveNoun.to_csv( './tsv/adjective-noun.tsv', columns=[ 'adjective', 'noun', 'frequency' ], sep='\t', index=False )

# unigrams
unigrams = subprocess.check_output( [ NGRAMS, CORPUS, '1' ] ).decode( 'utf-8' )
if ( not os.path.exists( './tsv/unigrams.tsv' ) ) :
	handle = open( './tsv/unigrams.tsv', 'w' ) 
	handle.write( "unigram\tfrequency\n" ) 
	handle.write( unigrams ) 
	handle.close()
if ( not os.path.exists( './figures/unigrams.png' ) ) :	
	data = unigrams.split( '\n' )
	handle   = open( './tmp/unigrams.tsv', 'w' )
	handle.write( '\n'.join( unigrams[ 0:CLOUDCOUNT ] ) ) 
	handle.close()
	subprocess.run( [ CLOUD, './tmp/unigrams.tsv', 'white', './figures/unigrams.png' ] )
data     = unigrams
unigrams = []
for unigram in data.split( '\n' ) :
	fields = unigram.split( '\t' )
	unigrams.append( fields[ 0 ] )
pattern      = '|'.join( unigrams[ 0:2 ] )
command      = "grep -Hice '" + pattern + "' ./txt/*.txt | tr ':' ' ' | sort -rnk2 | head -n3 | cut -d ' ' -f1"
unigramfiles = subprocess.check_output( command, shell=True ).decode( 'utf-8' )
unigramfiles = unigramfiles.rstrip().split( '\n' )

# bigrams
bigrams = subprocess.check_output( [ NGRAMS, CORPUS, '2' ] ).decode( 'utf-8' )
if ( not os.path.exists( './tsv/bigrams.tsv' ) ) :
	handle = open( './tsv/bigrams.tsv', 'w' ) 
	handle.write( "bigram\tfrequency\n" ) 
	handle.write( bigrams ) 
	handle.close() 
if ( not os.path.exists( './figures/bigrams.png' ) ) :	
	bigrams = bigrams.split( '\n' )
	handle  = open( './tmp/bigrams.tsv', 'w' )
	handle.write( '\n'.join( bigrams[ 0:CLOUDCOUNT ] ) ) 
	handle.close()
	subprocess.run( [ CLOUD,  './tmp/bigrams.tsv', 'white', './figures/bigrams.png' ] )
data     = bigrams
bigrams = []
for bigram in data.split( '\n' ) :
	fields = bigram.split( '\t' )
	bigrams.append( fields[ 0 ] )
pattern      = '|'.join( bigrams[ 0:2 ] )
command      = "grep -Hice '" + pattern + "' ./txt/*.txt | tr ':' ' ' | sort -rnk2 | head -n3 | cut -d ' ' -f1"
bigramfiles = subprocess.check_output( command, shell=True ).decode( 'utf-8' )
bigramfiles = bigramfiles.rstrip().split( '\n' )

# trigrams
if ( not os.path.exists( './tsv/trigrams.tsv' ) ) :
	handle = open( './tsv/trigrams.tsv', 'w' ) 
	handle.write( "trigram\tfrequency\n" ) 
	handle.write( subprocess.check_output( [ NGRAMS, CORPUS, '3' ] ).decode( 'utf-8' ) ) 
	handle.close() 

# quadgrams
if ( not os.path.exists( './tsv/quadgrams.tsv' ) ) :
	handle = open( './tsv/quadgrams.tsv', 'w' ) 
	handle.write( "quadgrams\tfrequency\n" ) 
	handle.write( subprocess.check_output( [ NGRAMS, CORPUS, '4' ] ).decode( 'utf-8' ) ) 
	handle.close() 

# topic model
topicSingleWords, topicSingleFiles, topicSingleTitles          = readModel( DIRECTORY, engine, 1, 1, 1 )
topicTripleWords, topicTripleFiles, topicTripleTitles          = readModel( DIRECTORY, engine, 3, 1, 1 )
topicQuintupleWords, topicQuintupleFiles, topicQuintupleTitles = readModel( DIRECTORY, engine, 5, 3, 1 )
subprocess.check_output( TOPICMODEL + ' ./txt 5 3 ./figures/topics.png', shell=True )

# debug
sys.stderr.write( '                number of items: ' + str( numberOfItems )           + '\n' )
sys.stderr.write( '                   sum of words: ' + str( sumOfWords )              + '\n' )
sys.stderr.write( '          average size in words: ' + str( averageSizeInWords )      + '\n' )
sys.stderr.write( '      average readability score: ' + str( averageReadabilityScore ) + '\n' )
sys.stderr.write( '\n' )
sys.stderr.write( '                          nouns: ' + '; '.join( nouns )       + '\n' )
sys.stderr.write( '                          verbs: ' + '; '.join( verbs )       + '\n' )
sys.stderr.write( '                     adjectives: ' + '; '.join( adjectives )  + '\n' )
sys.stderr.write( '                        adverbs: ' + '; '.join( adverbs )     + '\n' )
sys.stderr.write( '                       pronouns: ' + '; '.join( pronouns )    + '\n' )
sys.stderr.write( '                   proper nouns: ' + '; '.join( properNouns ) + '\n' )
sys.stderr.write( '                       keywords: ' + '; '.join( keywords )    + '\n' )
sys.stderr.write( '\n' )
sys.stderr.write( '       one topic; one dimension: ' + '; '.join( topicSingleWords )                                         + '\n' )
sys.stderr.write( '                        file(s): ' + ', '.join( [ '; '.join( files ) for files in topicSingleFiles ] )     + '\n' )
sys.stderr.write( '                      titles(s): ' + ' | '.join( [ '; '.join( titles ) for titles in topicSingleTitles ] ) + '\n' )
sys.stderr.write( '\n' )
sys.stderr.write( '    three topics; one dimension: ' + '; '.join( topicTripleWords )                                         + '\n' )
sys.stderr.write( '                        file(s): ' + ', '.join( [ '; '.join( files ) for files in topicTripleFiles ] )     + '\n' )
sys.stderr.write( '                      titles(s): ' + ' | '.join( [ '; '.join( titles ) for titles in topicTripleTitles ] ) + '\n' )
sys.stderr.write( '\n' )
sys.stderr.write( '  five topics; three dimensions: ' + '; '.join( topicQuintupleWords )                                         + '\n' )
sys.stderr.write( '                        file(s): ' + ', '.join( [ '; '.join( files ) for files in topicQuintupleFiles ] )     + '\n' )
sys.stderr.write( '                      titles(s): ' + ' | '.join( [ '; '.join( titles ) for titles in topicQuintupleTitles ] ) + '\n' )
sys.stderr.write( '\n' )

# open the template and do the substitutions
with open( TEMPLATE, 'r' ) as handle : html = handle.read()
html = html.replace( '##NUMBEROFITEMS##',          str( numberOfItems ) )
html = html.replace( '##SUMOFWORDS##',             str( sumOfWords ) )
html = html.replace( '##AVERAGESIZEINWORDS##',     str( averageSizeInWords)  )
html = html.replace( '##AVERAGEREADABILITSCORE##', str( averageReadabilityScore ) )
html = html.replace( '##FREQUENTUNIGRAMS##',       ', '.join( unigrams[ 0:50 ] ) )
html = html.replace( '##FREQUENTBIGRAMS##',        ', '.join( bigrams[ 0:50 ] ) )
html = html.replace( '##KEYWORDS##',               ', '.join( keywords ) )
html = html.replace( '##NOUNS##',                  ', '.join( nouns ) )
html = html.replace( '##VERBS##',                  ', '.join( verbs ) )
html = html.replace( '##PROPER##',                 ', '.join( properNouns ) )
html = html.replace( '##PRONOUNS##',               ', '.join( pronouns ) )
html = html.replace( '##ADJECTIVES##',             ', '.join( adjectives ) )
html = html.replace( '##ADVERBS##',                ', '.join( adverbs ) )
html = html.replace( '##TOPICSSINGLEWORD##',       topicSingleWords[ 0 ] )
html = html.replace( '##TOPICSSINGLEFILE##',       topicSingleFiles[ 0 ][ 0 ] )
html = html.replace( '##TOPICSSINGLETITLE##',      topicSingleTitles[ 0 ][ 0 ] )
html = html.replace( '##TOPICSTRIPLEWORD01##',     topicTripleWords[ 0 ] )
html = html.replace( '##TOPICSTRIPLEWORD02##',     topicTripleWords[ 1 ] )
html = html.replace( '##TOPICSTRIPLEWORD03##',     topicTripleWords[ 2 ] )
html = html.replace( '##TOPICSTRIPLEFILE01##',     topicTripleFiles[ 0 ][ 0 ] )
html = html.replace( '##TOPICSTRIPLEFILE02##',     topicTripleFiles[ 1 ][ 0 ] )
html = html.replace( '##TOPICSTRIPLEFILE03##',     topicTripleFiles[ 2 ][ 0 ] )
html = html.replace( '##TOPICSTRIPLETITLE01##',    topicTripleTitles[ 0 ][ 0 ] )
html = html.replace( '##TOPICSTRIPLETITLE02##',    topicTripleTitles[ 1 ][ 0 ] )
html = html.replace( '##TOPICSTRIPLETITLE03##',    topicTripleTitles[ 2 ][ 0 ] )
html = html.replace( '##TOPICSQUINWORDS01##',      ', '.join( topicQuintupleWords[ 0 ].split( ' ' ) ) )
html = html.replace( '##TOPICSQUINWORDS02##',      ', '.join( topicQuintupleWords[ 1 ].split( ' ' ) ) )
html = html.replace( '##TOPICSQUINWORDS03##',      ', '.join( topicQuintupleWords[ 2 ].split( ' ' ) ) )
html = html.replace( '##TOPICSQUINWORDS04##',      ', '.join( topicQuintupleWords[ 3 ].split( ' ' ) ) )
html = html.replace( '##TOPICSQUINWORDS05##',      ', '.join( topicQuintupleWords[ 4 ].split( ' ' ) ) )
html = html.replace( '##TOPICSQUINFILE01##',       topicQuintupleFiles[ 0 ][ 0 ] )
html = html.replace( '##TOPICSQUINFILE02##',       topicQuintupleFiles[ 1 ][ 0 ] )
html = html.replace( '##TOPICSQUINFILE03##',       topicQuintupleFiles[ 2 ][ 0 ] )
html = html.replace( '##TOPICSQUINFILE04##',       topicQuintupleFiles[ 3 ][ 0 ] )
html = html.replace( '##TOPICSQUINFILE05##',       topicQuintupleFiles[ 4 ][ 0 ] )
html = html.replace( '##TOPICSQUINTITLE01##',      topicQuintupleTitles[ 0 ][ 0 ] )
html = html.replace( '##TOPICSQUINTITLE02##',      topicQuintupleTitles[ 1 ][ 0 ] )
html = html.replace( '##TOPICSQUINTITLE03##',      topicQuintupleTitles[ 2 ][ 0 ] )
html = html.replace( '##TOPICSQUINTITLE04##',      topicQuintupleTitles[ 3 ][ 0 ] )
html = html.replace( '##TOPICSQUINTITLE05##',      topicQuintupleTitles[ 4 ][ 0 ] )
html = html.replace( '##FREQUENTUNIGRAMFILE01##',  unigramfiles[ 0 ] )
html = html.replace( '##FREQUENTUNIGRAMFILE02##',  unigramfiles[ 1 ] )
html = html.replace( '##FREQUENTUNIGRAMFILE03##',  unigramfiles[ 2 ] )
html = html.replace( '##FREQUENTBIGRAMFILE01##',   bigramfiles[ 0 ] )
html = html.replace( '##FREQUENTBIGRAMFILE02##',   bigramfiles[ 1 ] )
html = html.replace( '##FREQUENTBIGRAMFILE03##',   bigramfiles[ 2 ] )

# output and done
print( html )
exit()
