#!/usr/bin/env perl

# about.pl - summarize the contents of a study carrel

use constant TEMPLATE => './etc/about.htm';

use strict;

# number of items
my $numberofitems = `./bin/query.sh 'SELECT COUNT( id ) FROM bib;'`;
chop( $numberofitems );

# average size in words
my $averagesizeinwords = `./bin/query.sh 'SELECT ROUND(AVG( words ) ) FROM bib;'`;
chop( $averagesizeinwords );

# average readability score
my $averagereadabilityscore = `./bin/query.sh 'SELECT ROUND(AVG( flesch ) ) FROM bib;'`;
chop( $averagereadabilityscore );

# average readability score
my $averagereadabilityscore = `./bin/query.sh 'SELECT ROUND(AVG( flesch ) ) FROM bib;'`;
chop( $averagereadabilityscore );

# plot sizes and readability
`./bin/plot-sizes.sh  histogram ./tmp/sizes-histogram.jpg`;
`./bin/plot-sizes.sh  boxplot   ./tmp/sizes-boxplot.jpg`;
`./bin/plot-flesch.sh histogram ./tmp/flesch-histogram.jpg`;
`./bin/plot-flesch.sh boxplot   ./tmp/flesch-boxplot.jpg`;

# frequentngrams
my $frequentunigrams = `./bin/ngrams.pl ./etc/reader.txt 1 | head -n 7 | cut -f1`;
my @frequentunigrams = split /\n/, $frequentunigrams;
my $frequentbigrams  = `./bin/ngrams.pl ./etc/reader.txt 2 | head -n 7 | cut -f1`;
my @frequentbigrams  = split /\n/, $frequentbigrams;

# plot the respective word clouds
`./bin/ngrams.pl ./etc/reader.txt 1 | head -n 150 > ./tmp/unigrams.tsv`;
`./bin/cloud.py ./tmp/unigrams.tsv white ./tmp/unigrams.jpg`;
`./bin/ngrams.pl ./etc/reader.txt 2 | head -n 150 > ./tmp/bigrams.tsv`;
`./bin/cloud.py ./tmp/bigrams.tsv white ./tmp/bigrams.jpg`;

# plot even more word clouds
`./bin/cloud.sh nouns`;
`./bin/cloud.sh keywords`;
`./bin/cloud.sh pronouns`;
`./bin/cloud.sh verbs`;
`./bin/cloud.sh proper`;
`./bin/cloud.sh adjectives`;
`./bin/cloud.sh supadj`;
`./bin/cloud.sh supadv`;

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

# output and done
print $html;
exit;

