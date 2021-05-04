#!/usr/bin/env perl

# carrel2search.pl - query a database, transform the results into a JSON stream, and output an HTML page

# Eric Lease Morgan <emorgan@nd.edu> and Maria Carroll <mcarro10@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# June 23, 2020 - first documentation but based on prior work


# configure
use constant READERCORD_HOME => $ENV{ 'READERCORD_HOME' };
use constant CARRELS  => READERCORD_HOME . "/carrels";
use constant DATABASE => 'etc/reader.db';
use constant DRIVER   => 'SQLite';
use constant QUERY    => 'SELECT id, title, summary, flesch, date, words, author FROM bib;';
use constant TEMPLATE => READERCORD_HOME . "/etc/template-search.htm";

# require
use DBI;
use strict;
use JSON;

my $carrel = $ARGV[ 0 ];
if ( ! $carrel ) { die "Usage: $0 <short-name>\n" }

# initialize
my $driver   = DRIVER;
my $database = CARRELS . "/$carrel/" . DATABASE;
my $template = TEMPLATE;
my @data     = ();

# open the database and search
my $dbh = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
my $handle = $dbh->prepare( QUERY );
$handle->execute() or die $DBI::errstr;

# initialize the data and update it
while( my $bibliographics = $handle->fetchrow_hashref ) {

	# parse
	my $id       = $$bibliographics{ 'id' };
	my $title    = $$bibliographics{ 'title' };
	my $summary  = $$bibliographics{ 'summary' };
	my $flesch   = $$bibliographics{ 'flesch' };
	my $date     = $$bibliographics{ 'date' };
	my $words    = $$bibliographics{ 'words' };
	my $author   = $$bibliographics{ 'author' };

	# update
	push( @data, { 'id' => $id, 'title' => $title, 'summary' => $summary, 'flesch' => $flesch, 'date' => $date, 'words' => $words, 'author' => $author } );

}

# transform the data into json
my $json = JSON->new->encode( [ @data ] );

# read the template, do the substitution, output, and done
my $html =  &slurp( $template );
$html    =~ s/##JSON##/$json/e;
print $html;
exit;


sub slurp {
	my $f = shift;
	open ( F, $f ) or die "Can't open $f: $!\n";
	my $r = do { local $/; <F> };
	close F;
	return $r;
}

