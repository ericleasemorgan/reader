#!/usr/bin/perl

# search-solr.cgi - CGI interface to search a solr instance

# Eric Lease Morgan <emorgan@nd.edu>
# April 30, 2019 - first cut; based on Project English
# May    2, 2019 - added classification and files (urls)
# May    9, 2019 - added tsv output


# configure
use constant BASE       => 'http://dh.crc.nd.edu/sandbox/reader/hackaton/aesthetics/';
use constant CARREL     => 'A1556617766';
use constant FACETFIELD => ( 'facet_keyword', 'facet_person' );
use constant ROWS       => 499;
use constant SOLR       => 'http://localhost:8983/solr/carrels-reader';
use constant TXT        => './txt';

# require
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use HTML::Entities;
use strict;
use WebService::Solr;
use URI::Encode qw(uri_encode uri_decode);
use HTML::Escape qw/escape_html/;

# initialize
my $txt    = TXT;
my $base   = BASE;
my $carrel = CARREL;
my $cgi    = CGI->new;
my $query  = $cgi->param( 'query' );
my $solr   = WebService::Solr->new( SOLR );
my $html   = &template;

# sanitize query
my $sanitized = HTML::Entities::encode( $query );

# display the home page
if ( ! $query ) {

	$html =~ s/##QUERY##//;
	$html =~ s/##BASE##/$base/e;
	$html =~ s/##RESULTS##//;

}

# search
else {

	# re-initialize
	my $items = '';
	my @bids  = ();
	
	# build the search options
	my %search_options               = ();
	$search_options{ 'facet.field' } = [ FACETFIELD ];
	$search_options{ 'facet' }       = 'true';
	$search_options{ 'rows' }        = ROWS;

	# search
	my $response = $solr->search( "carrel:$carrel AND $query", \%search_options );

	# keywords facets
	my @facet_keyword = ();
	my $keyword_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_keyword } );
	foreach my $facet ( sort { $$keyword_facets{ $b } <=> $$keyword_facets{ $a } } keys %$keyword_facets ) {
	
		my $encoded = uri_encode( $facet );
		my $link = qq(<a href='./cgi-bin/search-solr.cgi?query=$sanitized AND keyword:"$encoded"'>$facet</a>);
		push @facet_keyword, $link . ' (' . $$keyword_facets{ $facet } . ')';
		
	}

	# author facets
	my @facet_person = ();
	my $person_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_person } );
	foreach my $facet ( sort { $$person_facets{ $b } <=> $$person_facets{ $a } } keys %$person_facets ) {
	
		my $encoded = uri_encode( $facet );
		my $link = qq(<a href='./cgi-bin/search-solr.cgi?query=$sanitized AND person:"$encoded"'>$facet</a>);
		push @facet_person, $link . ' (' . $$person_facets{ $facet } . ')';
		
	}

	# get the total number of hits
	my $total = $response->content->{ 'response' }->{ 'numFound' };

	# get number of hits
	my @hits = $response->docs;

	# loop through each document
	for my $doc ( $response->docs ) {
	
		# parse
		my $bid       = $doc->value_for( 'bid' );
		my $words     = $doc->value_for( 'words' );
		my $sentences = $doc->value_for( 'sentences' );
		my $flesch    = $doc->value_for( 'flesch' );
		my $filename  = "$txt/$bid.txt";
		my $summary   = $doc->value_for( 'summary' ) ? escape_html( $doc->value_for( 'summary' ) ) : $doc->value_for( 'summary' );
		
		# update the list of dids
		push( @bids, $bid );

		my @keywords = ();
		foreach my $keyword ($doc->values_for( 'keyword' ) ) {
		
			my $keyword = qq(<a href='./cgi-bin/search-solr.cgi?query=keyword:"$keyword"'>$keyword</a>);
			push( @keywords, $keyword );

		}
		@keywords = sort( @keywords );
				
		my @persons = ();
		foreach my $person ($doc->values_for( 'person' ) ) {
		
			my $classification = qq(<a href='./cgi-bin/search.cgi?query=person:"$person"'>$person</a>);
			push( @persons, $person );

		}
		@persons = sort( @persons );
				
		# create a item
		my $item = &item( $summary, scalar( @keywords ), scalar( @keywords ) );
		$item =~ s/##FILENAME##/$filename/eg;
		$item =~ s/##SUMMARY##/$summary/eg;
		$item =~ s/##KEYWORDS##/join( '; ', @keywords )/eg;
		$item =~ s/##SENTENCES##/$sentences/e;
		$item =~ s/##WORDS##/$words/e;
		$item =~ s/##FLESCH##/$flesch/e;

		# update the list of items
		$items .= $item;
					
	}	

	# build the html
	$html =  &results_template;
	$html =~ s/##RESULTS##/&results/e;
	$html =~ s/##QUERY##/$sanitized/e;
	$html =~ s/##TOTAL##/$total/e;
	$html =~ s/##HITS##/scalar( @hits )/e;
	$html =~ s/##FACETSKEYWORD##/join( '; ', @facet_keyword )/e;
	$html =~ s/##FACETPERSON##/join( '; ', @facet_person )/e;
	$html =~ s/##ITEMS##/$items/e;
	$html =~ s/##BASE##/$base/e;

}

# done
print $cgi->header( -type => 'text/html', -charset => 'utf-8');
print $html;
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


# search results template
sub results {

	return <<EOF
	<p>Your search found ##TOTAL## item(s) and ##HITS## item(s) are displayed.</p>
			
	<h3>Items</h3><ol>##ITEMS##</ol>
EOF

}


# specific item template
sub item {

	my $title    = shift;
	my $summary  = shift;
	my $keywords = shift;
	my $item      = "<li class='item'><a href='##FILENAME##'>##FILENAME##</a><ul>";
	if ( $summary ) { $item .= "<li style='list-style-type:circle'><strong>summary:</strong> ##SUMMARY##</li>" }
	if ( $keywords ) { $item .= "<li style='list-style-type:circle'><strong>keywords:</strong> ##KEYWORDS##</li>" }
	$item      .= "<li style='list-style-type:circle'><strong>statistics:</strong> ##SENTENCES## (sentences); ##WORDS## (words); ##FLESCH## (Flesch)</li>";
	$item .= "</ul></li>";
	
	return $item;

}



# root template
sub template {
	
	return <<EOF
<html>
<head>
	<title>Distant Reader Study Carrel</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<base href="##BASE##" />
	<link rel="stylesheet" href="./etc/style.css">
	<style>
		.item { margin-bottom: 1em }
	</style>
</head>
<body>
<div class="header">
	<h1>Distant Reader Study Carrel</h1>
</div>

<div class="col-3 col-m-3 menu">
  <ul>
		<li><a href="./cgi-bin/search-solr.cgi">Home</a></li>
 </ul>
</div>

<div class="col-9 col-m-9">

	<p>This is a full text index to a Distant Reader Study Carrel. Enter a query.</p>
	<p>
	<form method='GET' action='./cgi-bin/search-solr.cgi'>
	Query: <input type='text' name='query' value='##QUERY##' size='50' autofocus="autofocus"/>
	<input type='submit' value='Search' />
	</form>

	##RESULTS##

	<div class="footer">
		<p style='text-align: right'>
		Eric Lease Morgan<br />
		June 14, 2019
		</p>
	</div>

</div>

</body>
</html>
EOF

}


# results template
sub results_template {

	return <<EOF
<html>
<head>
	<title>Project Gutenberg - Search results</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<base href="##BASE##" />
	<link rel="stylesheet" href="./etc/style.css">
	<style>
		.item { margin-bottom: 1em }
	</style>
</head>
<body>
<div class="header">
	<h1>Distant Reader Study Carrel - Search results</h1>
</div>

<div class="col-3 col-m-3 menu">
  <ul>
		<li><a href="./cgi-bin/search-solr.cgi">Home</a></li>
 </ul>
</div>

	<div class="col-6 col-m-6">
		<p>
		<form method='GET' action='./cgi-bin/search-solr.cgi'>
		Query: <input type='text' name='query' value='##QUERY##' size='50' autofocus="autofocus"/>
		<input type='submit' value='Search' />
		</form>

		##RESULTS##
		
	</div>
	
	<div class="col-3 col-m-3">
	<h3>Keyword facets</h3><p>##FACETSKEYWORD##</p>
	<h3>Person facets</h3><p>##FACETPERSON##</p>
	</div>

</body>
</html>
EOF

}
