#!/usr/bin/perl

# search.cgi - CGI interface to search a solr instance

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# May 24, 2020 - migrating for Project CORD
# May 26, 2020 - added additional facets
# June 1, 2020 - added additional facets
# June 2, 2020 - added queueing of a carrel


# configure
use constant FACETFIELD   => ( 'facet_journal', 'year', 'facet_authors', 'facet_keywords', 'facet_entity', 'facet_type' );
use constant FIELDS       => 'id,title,doi,url,date,journal,abstract';
use constant SOLR         => 'http://solr-01:8983/solr/cord';
use constant ROWS         => 49;
use constant SEARCH2QUEUE => './search2queue.cgi?query=';

# require
use CGI;
use CGI::Carp qw( fatalsToBrowser );
use HTML::Entities;
use strict;
use WebService::Solr;
use URI::Encode qw( uri_encode uri_decode );

# initialize
my $cgi      = CGI->new;
my $query    = $cgi->param( 'query' );
my $html     = &template;
my $solr     = WebService::Solr->new( SOLR );

# sanitize query
my $sanitized = HTML::Entities::encode( $query );

# display the home page
if ( ! $query ) {

	$html =~ s/##QUERY##//;
	$html =~ s/##RESULTS##//;

}

# search
else {

	# re-initialize
	my $items        = '';
	my @document_ids = ();
	my $search2queue = SEARCH2QUEUE;
	
	# build the search options
	my %search_options = ();
	$search_options{ 'facet.field' } = [ FACETFIELD ];
	$search_options{ 'fl' }          = FIELDS;
	$search_options{ 'facet' }       = 'true';
	$search_options{ 'rows' }        = ROWS;

	# search
	my $response = $solr->search( $query, \%search_options );

	# build a list of journal facets
	my @facet_journal = ();
	my $journal_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_journal } );
	foreach my $facet ( sort { $$journal_facets{ $b } <=> $$journal_facets{ $a } } keys %$journal_facets ) {
	
		my $encoded = uri_encode( $facet );
		my $link = qq(<a href='./?query=$sanitized AND facet_journal:"$encoded"'>$facet</a>);
		push @facet_journal, $link . ' (' . $$journal_facets{ $facet } . ')';
		
	}

	# year
	my @facet_year = ();
	my $year_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ year } );
	foreach my $facet ( sort { $$year_facets{ $b } <=> $$year_facets{ $a } } keys %$year_facets ) {
	
		my $encoded = uri_encode( $facet );
		my $link = qq(<a href='./?query=$sanitized AND year:"$encoded"'>$facet</a>);
		push @facet_year, $link . ' (' . $$year_facets{ $facet } . ')';
		
	}

	# authors
	my @facet_author = ();
	my $author_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_authors } );
	foreach my $facet ( sort { $$author_facets{ $b } <=> $$author_facets{ $a } } keys %$author_facets ) {
	
		my $encoded = uri_encode( $facet );
		my $link = qq(<a href='./?query=$sanitized AND authors:"$encoded"'>$facet</a>);
		push @facet_author, $link . ' (' . $$author_facets{ $facet } . ')';
		
	}

	# keywords
	my @facet_keywords = ();
	my $keyword_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_keywords } );
	foreach my $facet ( sort { $$keyword_facets{ $b } <=> $$keyword_facets{ $a } } keys %$keyword_facets ) {
	
		my $encoded = uri_encode( $facet );
		my $link = qq(<a href='./?query=$sanitized AND keywords:"$encoded"'>$facet</a>);
		push @facet_keywords, $link . ' (' . $$keyword_facets{ $facet } . ')';
		
	}

	# entities
	my @facet_entity = ();
	my $entity_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_entity } );
	foreach my $facet ( sort { $$entity_facets{ $b } <=> $$entity_facets{ $a } } keys %$entity_facets ) {
	
		my $encoded = uri_encode( $facet );
		my $link = qq(<a href='./?query=$sanitized AND entity:"$encoded"'>$facet</a>);
		push @facet_entity, $link . ' (' . $$entity_facets{ $facet } . ')';
		
	}
	
	# entity types
	my @facet_type = ();
	my $type_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_type } );
	foreach my $facet ( sort { $$type_facets{ $b } <=> $$type_facets{ $a } } keys %$type_facets ) {
	
		my $encoded = uri_encode( $facet );
		my $link = qq(<a href='./?query=$sanitized AND type:"$encoded"'>$facet</a>);
		push @facet_type, $link . ' (' . $$type_facets{ $facet } . ')';
		
	}

	# get the total number of hits
	my $total = $response->content->{ 'response' }->{ 'numFound' };

	# get number of hits
	my @hits = $response->docs;

	# loop through each document
	for my $doc ( $response->docs ) {
	
		# parse
		my $document_id = $doc->value_for( 'id' );
		my $title       = $doc->value_for( 'title' );
		my $doi         = $doc->value_for( 'doi' );
		my $url         = $doc->value_for( 'url' );
		my $date        = $doc->value_for( 'date' );
		my $journal     = $doc->value_for( 'journal' );
		my $abstract    = $doc->value_for( 'abstract' );
						
		# create a item
		my $item =  &item;
		$item    =~ s/##TITLE##/$title/g;
		$item    =~ s/##DOCUMENTID##/$document_id/ge;
		$item    =~ s/##DOI##/$doi/ge;
		$item    =~ s/##URL##/$url/ge;
		$item    =~ s/##DATE##/$date/ge;
		$item    =~ s/##JOURNAL##/$journal/ge;
		$item    =~ s/##ABSTRACT##/$abstract/ge;

		# update the list of items
		$items .= $item;
					
	}	

	# build the html
	$html =  &results_template;
	$html =~ s/##RESULTS##/&results/e;
	$html =~ s/##QUERY##/$sanitized/eg;
	$html =~ s/##TOTAL##/$total/e;
	$html =~ s/##HITS##/scalar( @hits )/e;
	$html =~ s/##SEARCH2QUEUE##/$search2queue/e;
	$html =~ s/##ITEMS##/$items/e;
	$html =~ s/##FACETSAUTHOR##/join( '; ', @facet_author )/e;
	$html =~ s/##FACETSJOURNAL##/join( '; ', @facet_journal )/e;
	$html =~ s/##FACETSYEAR##/join( '; ', @facet_year )/e;
	$html =~ s/##FACETSKEYWORD##/join( '; ', @facet_keywords )/e;
	$html =~ s/##FACETSENTITY##/join( '; ', @facet_entity )/e;
	$html =~ s/##FACETSTYPE##/join( '; ', @facet_type )/e;

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
	<p>Your search found ##TOTAL## item(s) and ##HITS## item(s) are displayed. If you are satisfied with the results, then you may want to <a href='##SEARCH2QUEUE####QUERY##'>queue the creation of a study carrel</a> with them.</p>
	
	<h3>Items</h3><ol>##ITEMS##</ol>
EOF

}


# specific item template
sub item {

	#my $title       = shift;
	#my $document_id = shift;
	#my $doi         = shift;
	#my $url         = shift;
	
	my $item  = "<li class='item'><strong>##TITLE##</strong><ul>";
	$item    .= "<li style='list-style-type:circle'>##ABSTRACT##</li>";
	$item    .= "<li style='list-style-type:circle'>##DATE##</li>";
	$item    .= "<li style='list-style-type:circle'>##JOURNAL##</li>";
	$item    .= "<li style='list-style-type:circle'>##URL##</li>";
	$item    .= "<li style='list-style-type:circle'>##DOI##</li>";
	$item    .= "<li style='list-style-type:circle'>##DOCUMENTID##</li>";
	$item    .= "</ul></li>";
	
	return $item;

}



# root template
sub template {

	return <<EOF
<html>
<head>
	<title>Project CORD - Home</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" href="./etc/style.css">
	<style>
		.item { margin-bottom: 1em }
	</style>
</head>
<body>
<div class="header">
	<h1>Project CORD</h1>
</div>

<div class="col-3 col-m-3 menu">
  <ul>
		<li><a href="./">Home</a></li>
		<li><a href="./search2queue.cgi">Queue a carrel's creation</a></li>
 </ul>
</div>

<div class="col-9 col-m-9">

	<p>Use these pages to search the CORD data set and possibly queue the creation of study carrels. Enter a query.</p>
	<p>
	<form method='GET' action='./'>
	Query: <input type='text' name='query' value='##QUERY##' size='50' autofocus="autofocus"/>
	<input type='submit' value='Search' />
	</form>

	##RESULTS##

	<div class="footer">
		<p style='text-align: right'>
		Eric Lease Morgan &amp; Team Project CORD<br />
		May 24, 2020
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
	<title>Project CORD - Search results</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" href="./etc/style.css">
	<style>
		.item { margin-bottom: 1em }
	</style>
</head>
<body>
<div class="header">
	<h1>Project CORD - Search results</h1>
</div>

<div class="col-3 col-m-3 menu">
  <ul>
		<li><a href="./">Home</a></li>
		<li><a href="./search2queue.cgi">Queue a carrel's creation</a></li>
 </ul>
</div>

	<div class="col-6 col-m-6">
		<p>
		<form method='GET' action='./'>
		Query: <input type='text' name='query' value='##QUERY##' size='50' autofocus="autofocus"/>
		<input type='submit' value='Search' />
		</form>
		
		##RESULTS##
		
	</div>
	
	<div class="col-3 col-m-3">
	<h3>Year facets</h3><p>##FACETSYEAR##</p>
	<h3>Entity facets</h3><p>##FACETSENTITY##</p>
	<h3>Entity type facets</h3><p>##FACETSTYPE##</p>
	<h3>Keyword facets</h3><p>##FACETSKEYWORD##</p>
	<h3>Author facets</h3><p>##FACETSAUTHOR##</p>
	<h3>Journal facets</h3><p>##FACETSJOURNAL##</p>
	</div>

</body>
</html>
EOF

}
