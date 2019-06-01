#!/usr/bin/env perl

# ngrams.pl - output the most frequent ngrams in a text

# Eric Lease Morgan <eric_morgan@infomotions.com>
# June 1, 2019 - hacked for the Distant Reader in Washington DC


# configure
use constant STOPWORDS => './etc/stopwords.txt';

# require
use lib './etc';
use Lingua::EN::Ngram;
use strict;

# sanity check
my $file = $ARGV[ 0 ];
my $size = $ARGV[ 1 ];
if ( ! $file or ! $size ) {

	print "Usage: $0 <file> <integer>\n";
	exit;
	
}

# get stopwords
my $stopwords = STOPWORDS;
my %stopwords = ();
open F, "< $stopwords" or die "Can't open $stopwords ($!)\n";
while ( <F> ) { chop; $stopwords{ $_ }++ }
close F;

# initialize and count ngrams
my $ngram  = Lingua::EN::Ngram->new( file => $file );
my $ngrams = $ngram->ngram( $size );

# process all the ngrams
my $index = 0;
foreach my $phrase ( sort { $$ngrams{ $b } <=> $$ngrams{ $a } } keys %$ngrams ) {
		
	# check for punctuation in each token or phrase
	my $found = 0;
	foreach ((split / /, $phrase )) {
	
		# remove punctuation
		if ( $_ =~ /[[:punct:]]/ ) {
	
			$found = 1;
			last;
		
		}
		
		# conditionally remove stopwords
		if ( $size < 3 ) {
		
			if ( $stopwords{ $_ } ) {
		
				$found = 1;
				last;

			}
		
		}
		
	}
	
	# don't want found tokens
	next if ( $found );
		
	# don't want single frequency phrases
	last if ( $$ngrams{ $phrase } == 1 );
	
	# echo
	print $$ngrams{ $phrase }, "\t$phrase\n";
	
}

# done
exit;
