#!/usr/bin/env perl

# search.pl - command-line interface to search a solr instance

# Eric Lease Morgan <emorgan@nd.edu>
# April 30, 2019 - first cut; based on earlier work
# May    2, 2019 - added classification and files (urls)
# July 8, 2019 - added author, title, and date


# configure
use constant FACETFIELD => ( 'facet_keyword', 'facet_person' );
use constant SOLR       => 'http://localhost:8983/solr/carrels-reader';
use constant TXT        => './txt';
use constant CARREL     => 'A443285322';

# require
use strict;
use WebService::Solr;

# get input; sanity check
my $query  = $ARGV[ 0 ];
if ( ! $query ) { die "Usage: $0 <query>\n" }

# initialize
my $solr   = WebService::Solr->new( SOLR );
my $txt    = TXT;
my $carrel = CARREL;

# build the search options
my %search_options = ();
$search_options{ 'facet.field' } = [ FACETFIELD ];
$search_options{ 'facet' }       = 'true';

# search
my $response = $solr->search( "carrel:$carrel AND $query", \%search_options );

# build a list of keyword facets
my @facet_keyword = ();
my $keyword_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_keyword } );
foreach my $facet ( sort { $$keyword_facets{ $b } <=> $$keyword_facets{ $a } } keys %$keyword_facets ) { push @facet_keyword, $facet . ' (' . $$keyword_facets{ $facet } . ')'; }

# build a list of person facets
my @facet_person = ();
my $person_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_person } );
foreach my $facet ( sort { $$person_facets{ $b } <=> $$person_facets{ $a } } keys %$person_facets ) { push @facet_person, $facet . ' (' . $$person_facets{ $facet } . ')'; }

# get the total number of hits
my $total = $response->content->{ 'response' }->{ 'numFound' };

# get number of hits returned
my @hits = $response->docs;

# start the output
print "Your search found $total item(s) and " . scalar( @hits ) . " item(s) are displayed.\n\n";
print '   person facets: ', join( '; ', @facet_person ), "\n\n";
print '  keyword facets: ', join( '; ', @facet_keyword ), "\n\n";

# loop through each document
for my $doc ( $response->docs ) {

	# parse
	my $bid       = $doc->value_for(  'bid' );
	my $words     = $doc->value_for(  'words' );
	my $author    = $doc->value_for(  'author' );
	my $title     = $doc->value_for(  'title' );
	my $date      = $doc->value_for(  'date' );
	my $sentences = $doc->value_for(  'sentences' );
	my $flesch    = $doc->value_for(  'flesch' );
	my $summary   = $doc->value_for(  'summary' );
	my @keywords  = $doc->values_for( 'keyword' );
	my @persons   = $doc->values_for( 'person' );
	my $filename  = "$txt/$bid.txt";
	
	# output
	print "$bid\n";
	print "     author: $author\n";
	print "      title: $title\n";
	print "       date: $date\n";
	print "     summary: $summary\n";
	print "  keyword(s): " . join( '; ', @keywords ), "\n";
	print "  persons(s): " . join( '; ', @persons ), "\n";
	print "   sentences: $sentences\n";
	print "       words: $words\n";
	print "      flesch: $flesch\n";
	print "    filename: $filename\n";
	print "\n";

}

# done
exit;


# convert an array reference into a hash
sub get_facets {

	my $array_ref = shift;
	
	my %facets;
	my $i = 0;
	foreach ( @$array_ref ) {
	
		my $k = $array_ref->[ $i ]; $i++;
		my $v = $array_ref->[ $i ]; $i++;
		next if ( ! $v );
		$facets{ $k } = $v;
	 
	}
	
	return \%facets;
	
}

