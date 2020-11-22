#!/usr/bin/env perl

# index.pl - make the content searchable

# Eric Lease Morgan <emorgan@nd.edu>
# April 30, 2019 - first investigations; based on other work


# configure
use constant DATABASE => './etc/cord.db';
use constant DRIVER   => 'SQLite';
use constant QUERY    => qq(SELECT document_id, title, year, abstract, date, journal, source, license, doi, arxiv_id, cord_uid, mag_id, pmc_id, pubmed_id, who_id, sha, pdf_json, pmc_json FROM documents LIMIT 10;);
use constant SOLR     => 'http://10.0.1.11:8983/solr/reader-cord';

# require
use DBI;
use strict;
use WebService::Solr;

# initialize
my $solr      = WebService::Solr->new( SOLR );
my $driver    = DRIVER; 
my $database  = DATABASE;
my $dbh       = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
binmode( STDOUT, ':utf8' );

# find documents
my $handle = $dbh->prepare( QUERY );
$handle->execute() or die $DBI::errstr;

# process each document
while( my $document = $handle->fetchrow_hashref ) {
	
	# parse the title data
	my $id        = $$document{ 'document_id' };
	my $title     = $$document{ 'title' };
	my $year      = $$document{ 'year' };
	my $abstract  = $$document{ 'abstract' };
	my $date      = $$document{ 'date' };
	my $journal   = $$document{ 'journal' };
	my $source    = $$document{ 'source' };
	my $license   = $$document{ 'license' };
	my $doi       = $$document{ 'doi' };
	my $arxiv_id  = $$document{ 'arxiv_id' };
	my $cord_uid  = $$document{ 'cord_uid' };
	my $mag_id    = $$document{ 'mag_id' };
	my $pmc_id    = $$document{ 'pmc_id' };
	my $pubmed_id = $$document{ 'pubmed_id' };
	my $who_id    = $$document{ 'who_id' };
	my $sha       = $$document{ 'sha' };
	my $pdf_json  = $$document{ 'pdf_json' };
	my $pmc_json  = $$document{ 'pmc_json' };
	
	# get authors
	my @authors   = ();
	my $subhandle = $dbh->prepare( qq(SELECT author FROM authors WHERE document_id='$id';) );
	$subhandle->execute() or die $DBI::errstr;
	while( my @author = $subhandle->fetchrow_array ) {
	
		# update list of authors
		push @authors, $author[ 0 ];
				
	}

	# get named entities
	my @entities   = ();
	my $subhandle = $dbh->prepare( qq(SELECT DISTINCT( entity ) FROM ent WHERE document_id='$id' AND (type IS 'PERSON' OR type IS 'DISEASE'); ) );
	$subhandle->execute() or die $DBI::errstr;
	while( my @entity = $subhandle->fetchrow_array ) {
	
		# update list of authors
		push @entities, $entity[ 0 ];
				
	}

	# get keywords
	my @keywords   = ();
	my $subhandle = $dbh->prepare( qq(SELECT keyword FROM wrd WHERE document_id='$id';) );
	$subhandle->execute() or die $DBI::errstr;
	while( my @keyword = $subhandle->fetchrow_array ) {
	
		# update list of authors
		push @keywords, $keyword[ 0 ];
				
	}

	# debug; dump
	warn "           id: $id\n";
	warn "        title: $title\n";
	warn "         year: $year\n";
	warn "     abstract: $abstract\n";
	warn "         date: $date\n";
	warn "      journal: $journal\n";
	warn "       source: $source\n";
	warn "      license: $license\n";
	warn "          doi: $doi\n";
	warn "     arxiv_id: $arxiv_id\n";
	warn "     cord_uid: $cord_uid\n";
	warn "       mag_id: $mag_id\n";
	warn "       pmc_id: $pmc_id\n";
	warn "    pubmed_id: $pubmed_id\n";
	warn "       who_id: $who_id\n";
	warn "          sha: $sha\n";
	warn "     pdf_json: $pdf_json\n";
	warn "     pmc_json: $pmc_json\n";
	warn "\n";
	warn "   authors(s): ", join( '; ', @authors ), "\n";
	warn "\n";
	warn "  entities(s): ", join( '; ', @entities ), "\n";
	warn "\n";
	warn "   keyword(s): ", join( '; ', @keywords ), "\n";
	warn "\n";
		
	# create data
	my $solr_id        = WebService::Solr::Field->new( 'id'        => $id );
	my $solr_title     = WebService::Solr::Field->new( 'title'     => $title );
	my $solr_year      = WebService::Solr::Field->new( 'year'      => $year );
	my $solr_abstract  = WebService::Solr::Field->new( 'abstract'  => $abstract );
	my $solr_date      = WebService::Solr::Field->new( 'date'      => $date );
	my $solr_journal   = WebService::Solr::Field->new( 'journal'   => $journal );
	my $solr_source    = WebService::Solr::Field->new( 'source'    => $source );
	my $solr_license   = WebService::Solr::Field->new( 'license'   => $license );
	my $solr_doi       = WebService::Solr::Field->new( 'doi'       => $doi );
	my $solr_arxiv_id  = WebService::Solr::Field->new( 'arxiv_id'  => $arxiv_id );
	my $solr_cord_uid  = WebService::Solr::Field->new( 'cord_uid'  => $cord_uid );
	my $solr_mag_id    = WebService::Solr::Field->new( 'mag_id'    => $mag_id );
	my $solr_pmc_id    = WebService::Solr::Field->new( 'pmc_id'    => $pmc_id );
	my $solr_pubmed_id = WebService::Solr::Field->new( 'pubmed_id' => $pubmed_id );
	my $solr_who_id    = WebService::Solr::Field->new( 'who_id'    => $who_id );
	my $solr_sha       = WebService::Solr::Field->new( 'sha'       => $sha );
	my $solr_pdf_json  = WebService::Solr::Field->new( 'pdf_json'  => $pdf_json );
	my $solr_pmc_json  = WebService::Solr::Field->new( 'pmc_json'  => $pmc_json );

	# fill a solr document with simple fields
	my $doc = WebService::Solr::Document->new;
	$doc->add_fields( $solr_id, $solr_title, $solr_year, $solr_abstract, $solr_date, $solr_journal, $solr_source, $solr_license, $solr_doi, $solr_arxiv_id, $solr_cord_uid, $solr_mag_id, $solr_pmc_id, $solr_pubmed_id, $solr_who_id, $solr_sha, $solr_pdf_json, $solr_pmc_json );

	# add complex fields
	foreach ( @authors ) { $doc->add_fields(( WebService::Solr::Field->new( 'facet_authors'   => $_ ))) }
	foreach ( @authors ) { $doc->add_fields(( WebService::Solr::Field->new( 'authors'         => $_ ))) }
	foreach ( @entities ) { $doc->add_fields(( WebService::Solr::Field->new( 'facet_entity'   => $_ ))) }
	foreach ( @entities ) { $doc->add_fields(( WebService::Solr::Field->new( 'entity'         => $_ ))) }
	foreach ( @keywords ) { $doc->add_fields(( WebService::Solr::Field->new( 'facet_keywords' => $_ ))) }
	foreach ( @keywords ) { $doc->add_fields(( WebService::Solr::Field->new( 'keywords'       => $_ ))) }

	# save/index
	$solr->add( $doc );

}

# done
exit;


sub slurp {

	my $f = shift;
	open ( F, $f ) or die "Can't open $f: $!\n";
	my $r = do { local $/; <F> };
	close F;
	return $r;

}
