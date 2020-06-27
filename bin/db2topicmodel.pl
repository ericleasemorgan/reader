#!/usr/bin/env perl

# db2topicmodel.pl - search a carrel for specific fields, output a data structure suitable for jslda.js (topic modeling)

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# August   11, 2019 - first cut; at the cabin before Philadelphia
# September 6, 2019 - quoted file names
# June     27, 2020 - re-wrote in Perl for Project CORD; we now have dates, but not really


# configure
use constant DATABASE => './etc/reader.db';
use constant DRIVER   => 'SQLite';
use constant SELECT   => 'SELECT id, date, summary FROM bib;';

# require
use DBI;
use strict;

# initialize
my $driver    = DRIVER; 
my $database  = DATABASE;
my $dbh       = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
my $data      = '';
binmode( STDOUT, ':utf8' );

# find documents
my $handle = $dbh->prepare( SELECT );
$handle->execute() or die $DBI::errstr;

# process each document
while( my $record = $handle->fetchrow_hashref ) {

	# parse
	my $id      = $$record{ 'id' };
	my $date    = $$record{ 'date' };
	my $summary = $$record{ 'summary' };
	
	# normalize
	$date    = substr( $date, 0, 4 );
	
	$data .= join( "\t", ( $id, $date, $summary ) ) . "\n";
}

# output and done
print $data;
exit;


sub slurp {

	my $f = shift;
	open ( F, $f ) or die "Can't open $f: $!\n";
	my $r = do { local $/; <F> };
	close F;
	return $r;

}



