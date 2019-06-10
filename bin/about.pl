#!/usr/bin/env perl

# about.pl - summarize the contents of a study carrel

use constant TEMPLATE => '/export/reader/etc/about.htm';

use strict;

# number of items
my $numberofitems = `../../bin/query.sh 'SELECT COUNT( id ) FROM bib;'`;
chop( $numberofitems );

# average size in words
my $averagesizeinwords = `../../bin/query.sh 'SELECT ROUND(AVG( words ) ) FROM bib;'`;
chop( $averagesizeinwords );

# average readability score
my $averagereadabilityscore = `../../bin/query.sh 'SELECT ROUND(AVG( flesch ) ) FROM bib;'`;
chop( $averagereadabilityscore );

# average readability score
my $averagereadabilityscore = `../../bin/query.sh 'SELECT ROUND(AVG( flesch ) ) FROM bib;'`;
chop( $averagereadabilityscore );

# plot sizes and readability
if ( ! -e './figures/sizes-histogram.png' )  { `../../bin/plot-sizes.sh  histogram ./figures/sizes-histogram.png`  }
if ( ! -e './figures/sizes-boxplot.png' )    { `../../bin/plot-sizes.sh  boxplot   ./figures/sizes-boxplot.png`    }
if ( ! -e './figures/flesch-histogram.png' ) { `../../bin/plot-flesch.sh histogram ./figures/flesch-histogram.png` }
if ( ! -e './figures/flesch-boxplot.png' )   { `../../bin/plot-flesch.sh boxplot   ./figures/flesch-boxplot.png`   }  

# frequent ngrams
my $frequentunigrams = `../../bin/ngrams.pl ./etc/reader.txt 1 | head -n 25 | cut -f1`;
my @frequentunigrams = split /\n/, $frequentunigrams;
my $frequentbigrams  = `../../bin/ngrams.pl ./etc/reader.txt 2 | head -n 25 | cut -f1`;
my @frequentbigrams  = split /\n/, $frequentbigrams;

# topic model with a single word and single file
my $model  = `../../bin/topic-model.py ./txt 1 1`;
my $topics = &readModel( $model, 1 );
my ( $topicssingle, $topicssinglefile ) = split( "\t", @$topics[ 0 ] );

# topic model with three words and a single file
my $model  = `../../bin/topic-model.py ./txt 3 1`;
my $topics = &readModel( $model, 1 );
my ( $topicstriple01, $topicstriplefile01 ) = split( "\t", @$topics[ 0 ] );
my ( $topicstriple02, $topicstriplefile02 ) = split( "\t", @$topics[ 1 ] );
my ( $topicstriple03, $topicstriplefile03 ) = split( "\t", @$topics[ 2 ] );

# topic model with five words, five dimensions and a single file
my $model  = `../../bin/topic-model.py ./txt 5 3 ./figures/topics.png`;
my $topics = &readModel( $model, 1 );
my ( $topicsquin01, $topicsquinfile01 ) = split( "\t", @$topics[ 0 ] );
my ( $topicsquin02, $topicsquinfile02 ) = split( "\t", @$topics[ 1 ] );
my ( $topicsquin03, $topicsquinfile03 ) = split( "\t", @$topics[ 2 ] );
my ( $topicsquin04, $topicsquinfile04 ) = split( "\t", @$topics[ 3 ] );
my ( $topicsquin05, $topicsquinfile05 ) = split( "\t", @$topics[ 4 ] );

# plot the respective word clouds
`../../bin/ngrams.pl ./etc/reader.txt 1 | head -n 150 > ./tmp/unigrams.tsv`;
if ( ! -e './figures/unigrams.png' ) { `../../bin/cloud.py ./tmp/unigrams.tsv white ./figures/unigrams.png` }
`../../bin/ngrams.pl ./etc/reader.txt 2 | head -n 150 > ./tmp/bigrams.tsv`;
if ( ! -e './figures/bigrams.png' ) { `../../bin/cloud.py ./tmp/bigrams.tsv white ./figures/bigrams.png`; }

# get top 25 nouns
my $nouns = `../../bin/query.sh 'SELECT lemma FROM pos where pos like "N%%" GROUP BY lemma ORDER BY COUNT( lemma ) DESC LIMIT 25;'`;
my @nouns = split /\n/, $nouns;

# get top 25 verbs
my $verbs = `../../bin/query.sh 'SELECT lemma FROM pos where pos like "V%%" GROUP BY lemma ORDER BY COUNT( lemma ) DESC LIMIT 25;'`;
my @verbs = split /\n/, $verbs;

# get top 25 pronouns
my $pronouns = `../../bin/query.sh 'SELECT lower(token) FROM pos where pos is "PRP" GROUP BY lower(token) ORDER BY count(lower(token)) DESC LIMIT 25;'`;
my @pronouns = split /\n/, $pronouns;

# get top 25 proper nouns
my $proper = `../../bin/query.sh 'SELECT token FROM pos where pos LIKE "NNP%%" GROUP BY token ORDER BY COUNT( token ) DESC LIMIT 25;'`;
my @proper = split /\n/, $proper;

# get top 25 adjectives
my $adjectives = `../../bin/query.sh 'SELECT lemma FROM pos where pos like "J%%" GROUP BY lemma ORDER BY COUNT( lemma ) DESC LIMIT 25;'`;
my @adjectives = split /\n/, $adjectives;

# get top 25 adverbs
my $adverbs = `../../bin/query.sh 'SELECT lemma FROM pos where pos like "R%%" GROUP BY lemma ORDER BY COUNT( lemma ) DESC LIMIT 25;'`;
my @adverbs = split /\n/, $adverbs;

# get top 3 keywords
my $keywords = `../../bin/query.sh 'SELECT keyword FROM wrd GROUP BY keyword ORDER BY COUNT( keyword ) DESC LIMIT 2;'`;
my @keywords = split /\n/, $keywords;
$keywords = '\b' . join( '\b|\b', @keywords ) . '\b';
my $concordance = `../../bin/concordance.pl ./etc/reader.txt '$keywords' | shuf -n 50`;

# get top 7 keywords
my $keywords = `../../bin/query.sh 'SELECT keyword FROM wrd GROUP BY keyword ORDER BY COUNT( keyword ) DESC LIMIT 25;'`;
my @keywords = split /\n/, $keywords;

# plot even more word clouds
`../../bin/cloud.sh nouns`;
`../../bin/cloud.sh keywords`;
`../../bin/cloud.sh pronouns`;
`../../bin/cloud.sh verbs`;
`../../bin/cloud.sh proper`;
`../../bin/cloud.sh adjectives`;
`../../bin/cloud.sh adverbs`;
`../../bin/cloud.sh supadj`;
`../../bin/cloud.sh supadv`;

# slurp
my $template = TEMPLATE;
open HTML, "< $template" or die "Can't open $template ($!)\n";
my $html = do { local $/; <HTML> };
close HTML;

# do the substitutions
$html =~ s/##NUMBEROFITEMS##/$numberofitems/;
$html =~ s/##AVERAGESIZEINWORDS##/$averagesizeinwords/;
$html =~ s/##AVERAGEREADABILITSCORE##/$averagereadabilityscore/;
$html =~ s/##FREQUENTUNIGRAMS##/join( ', ', @frequentunigrams )/e;
$html =~ s/##FREQUENTBIGRAMS##/join( ', ', @frequentbigrams )/e;
$html =~ s/##KEYWORDS##/join( ', ', @keywords )/e;
$html =~ s/##NOUNS##/join( ', ', @nouns )/e;
$html =~ s/##VERBS##/join( ', ', @verbs )/e;
$html =~ s/##PRONOUNS##/join( ', ', @pronouns )/e;
$html =~ s/##PROPER##/join( ', ', @proper )/e;
$html =~ s/##ADJECTIVES##/join( ', ', @adjectives )/e;
$html =~ s/##ADVERBS##/join( ', ', @adverbs )/e;
$html =~ s/##CONCORDANCE##/$concordance/e;
$html =~ s/##TOPICSSINGLE##/$topicssingle/e;
$html =~ s/##TOPICSSINGLEFILE##/$topicssinglefile/eg;
$html =~ s/##TOPICSTRIPLE01##/$topicstriple01/eg;
$html =~ s/##TOPICSTRIPLE02##/$topicstriple02/eg;
$html =~ s/##TOPICSTRIPLE03##/$topicstriple03/eg;
$html =~ s/##TOPICSTRIPLEFILE01##/$topicstriplefile01/eg;
$html =~ s/##TOPICSTRIPLEFILE02##/$topicstriplefile02/eg;
$html =~ s/##TOPICSTRIPLEFILE03##/$topicstriplefile03/eg;
$html =~ s/##TOPICSQUIN01##/$topicsquin01/eg;
$html =~ s/##TOPICSQUIN02##/$topicsquin02/eg;
$html =~ s/##TOPICSQUIN03##/$topicsquin03/eg;
$html =~ s/##TOPICSQUIN04##/$topicsquin04/eg;
$html =~ s/##TOPICSQUIN05##/$topicsquin05/eg;
$html =~ s/##TOPICSQUINFILE01##/$topicsquinfile01/eg;
$html =~ s/##TOPICSQUINFILE02##/$topicsquinfile02/eg;
$html =~ s/##TOPICSQUINFILE03##/$topicsquinfile03/eg;
$html =~ s/##TOPICSQUINFILE04##/$topicsquinfile04/eg;
$html =~ s/##TOPICSQUINFILE05##/$topicsquinfile05/eg;

# output and done
print $html;
exit;


sub readModel {

	# get input
	my $model  = shift;
	my $n      = shift;
	my @topics = ();
		
	foreach ( split( "\n", $model ) ) {

		# parse
		my ( $id, $score, $words, $files ) = split( "\t", $_ );
	
		# parse some more
		my @files = split( ';', $files );
			
		# create listing of n desired documents
		my @documents = ();
		for ( my $i = 0; $i <= $n - 1; $i++ ) { push( @documents, $files[ $i ] ) }
				
		# output
		push( @topics, join( "\t", ( $words, join( ' ', @documents ) ) ) );

	}
		
	return [ @topics ];

}