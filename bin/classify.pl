#!/usr/bin/perl

# classify.pl - list most significant words in a text; based on http://en.wikipedia.org/wiki/Tfidf

# Eric Lease Morgan <eric_morgan@infomotions.com>
# April 10, 2009 - first investigations; based on search.pl
# April 12, 2009 - added dynamic corpus


# define
use constant LOWERBOUNDS  => .05;
use constant EXTRAS       => ( 'upon', 'one', 'though', 'will', 'shall' );

my $directory = $ARGV[ 0 ];
if ( ! $directory ) { die "Usage $0 <directory>\n" }

# use/require
use strict;
use Lingua::StopWords qw( getStopWords );
require './etc/tfidf-toolbox.pl';

# initialize
my @corpus    = &corpus( $directory );
my $stopwords = &getStopWords( 'en' );

# update stopwords
foreach ( EXTRAS ) { $$stopwords{ $_ } = 1 }

# index, sans stopwords
my %index = ();
foreach my $file ( @corpus ) { $index{ $file } = &index( $file, $stopwords ) }

# classify (tag) each document
my %terms = ();
foreach my $file ( @corpus ) {

	my $tags = &classify( \%index, $file, [ @corpus ] );
	my $found = 0;
	my $directory = $directory;
	
	# list tags greater than a given score
	foreach my $tag ( sort { $$tags{ $b } <=> $$tags{ $a } } keys %$tags ) {
	
		if ( $$tags{ $tag } > LOWERBOUNDS ) {
		
			$file =~ s/$directory\///e;
			print "$tag (" . $$tags{ $tag } . ") $file\n";
			
			$terms{ $tag }++;
			$found = 1;
			
		}
		
		else { last }
	
	}
	
	print "\n";
	
	# accomodate tags with low scores
	#if ( ! $found ) {
	#
	#	my $n = 0;
	#	foreach my $tag ( sort { $$tags{ $b } <=> $$tags{ $a } } keys %$tags ) {
	#		
	#		$terms{ $tag }++;
	#		$n++;
	#		last if ( $n == NUMBEROFTAGS );
	#		
	#	}
	#
	#}
		
}

foreach ( sort { $terms{ $b } <=> $terms{ $a } } keys %terms ) {

	my $key   = $_;
	my $value = $terms{ $key };
	print "$key\t$value\n";

}


# done; more fun!
exit;


