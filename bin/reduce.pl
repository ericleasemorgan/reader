#!/usr/bin/env perl

# reduce.pl - given a directory name, create an sqlite database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, distributed under a GNU Public License

# June     28, 2018 - first investigations
# July      8, 2019 - changed shape of bibliographics
# September 1, 2019 - added cache and txt fields to bib
# May      20, 2020 - migrating to Reader CORD


# configure
use constant DRIVER   => 'SQLite';
use constant DATABASE => './etc/cord.db';

# require
use DBI;
use strict;
use File::Basename;
 
# sanity check
my $type = $ARGV[ 0 ];
my $file = $ARGV[ 1 ];
if ( ! $type | ! $file ) { &usage }

# initialize
my $driver   = DRIVER;
my $database = DATABASE;
my $reader   = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;

# extract the document_id from the given filename; 'wish they had given me a key to begin with!
my $document_id = &filename2id( basename( $file ) );

# branch according to the desired work
if    ( $type eq 'pos' ) { &pos( $reader, $file ) }
elsif ( $type eq 'ent' ) { &ent( $reader, $file ) }
elsif ( $type eq 'wrd' ) { &wrd( $reader, $file, $document_id ) }
elsif ( $type eq 'adr' ) { &adr( $reader, $file ) }
elsif ( $type eq 'url' ) { &url( $reader, $file ) }
elsif ( $type eq 'bib' ) { &bib( $reader, $file ) }
else { &usage }

# done
exit;

sub usage { die "Usage: $0 <pos|ent|wrd|adr|url|bib> <file>\n" }


# extract our document id from the filename; yuck;
sub filename2id {

	my $filename =  shift;
	my @parts    =  split( '-', $filename );
	my $id       =  $parts[ 1 ];
	$id          =~ s/^0+//;
	
	# done
	return $id;
	
}

sub wrd {

	# get input
	my $dbh         = shift;
	my $file        = shift;
	my $document_id = shift;
	
	# prepare the database
	my $sth = $dbh->prepare( "BEGIN TRANSACTION;" ) or die $DBI::errstr;
	$sth->execute or die $DBI::errstr;
	$sth = $dbh->prepare( "INSERT INTO wrd ( 'document_id', 'keyword' ) VALUES ( ?, ? );" ) or die $DBI::errstr;

	# open the given file
	open FILE, " < $file" or die "Can't open $file ($!)\n";

	# process each line in the file
	my $counter = 0;
	while ( <FILE> ) {

		# increment; skip the first line
		$counter++;
		next if ( $counter == 1 );
	
		# parse, escape, and do the work
		chop;
		my ( $id, $keyword ) = split( "\t", $_ );
		$keyword =~ s/'/''/g;
		$sth->execute( $document_id, $keyword ) or die $DBI::errstr;

	}
	
	# close the database
	$sth = $dbh->prepare( "END TRANSACTION;" ) or die $DBI::errstr;
	$sth->execute or die $DBI::errstr;

 }

sub bib {

	warn "=== reduce.pl bib ===\n";
	
	# get input
	my $dbh  = shift;
	my $file = shift;
	
	# prepare the database
	my $sth = $dbh->prepare( "BEGIN TRANSACTION;" ) or die $DBI::errstr;
	$sth->execute or die $DBI::errstr;
	#$sth = $dbh->prepare( "INSERT INTO bib ( 'id', 'author', 'title', 'date', 'pages', 'extension', 'mime', 'words', 'sentence', 'flesch', 'summary' ) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);" ) or die $DBI::errstr;
	$sth = $dbh->prepare( "UPDATE bib SET author = ?, title = ?, date = ?, pages = ?, extension = ?, mime = ?, words = ?, sentence = ?, flesch = ?, summary = ?, cache = ?, txt = ? where id = ?;" ) or die $DBI::errstr;

	# open the given file
	open FILE, " < $file" or die "Can't open $file ($!)\n";

	# process each line in the file
	my $counter = 0;
	while ( <FILE> ) {

		# increment; skip the first line
		$counter++;
		next if ( $counter == 1 );
	
		# parse, escape, and do the work
		chop;
		my ( $id, $author, $title, $date, $pages, $extension, $mime, $words, $sentences, $flesch, $summary, $cache, $txt ) = split( "\t", $_ );
		warn "         id = $id\n";
		warn "     author = $author\n";
		warn "      title = $title\n";
		warn "       date = $date\n";
		warn "      pages = $pages\n";
		warn "  extension = $extension\n";
		warn "       mime = $mime\n";
		warn "      words = $words\n";
		warn "  sentences = $sentences\n";
		warn "     flesch = $flesch\n";
		warn "    summary = $summary\n";
		warn "      cache = $cache\n";
		warn "       txt  = $txt\n";
		
		$id      =~ s/'/''/g;
		$summary =~ s/'/''/g;
		$author  =~ s/'/''/g;
		$title   =~ s/'/''/g;
		$cache   =~ s/'/''/g;
		$txt     =~ s/'/''/g;
		
		$sth->execute( $author, $title, $date, $pages, $extension, $mime, $words, $sentences, $flesch, $summary, $cache, $txt, $id ) or die $DBI::errstr;

	}
	
	# close the database
	$sth = $dbh->prepare( "END TRANSACTION;" ) or die $DBI::errstr;
	$sth->execute or die $DBI::errstr;


 }

sub url {

	# get input
	my $dbh  = shift;
	my $file = shift;
	
	# prepare the database
	my $sth = $dbh->prepare( "BEGIN TRANSACTION;" ) or die $DBI::errstr;
	$sth->execute or die $DBI::errstr;
	$sth = $dbh->prepare( "INSERT INTO url ( 'id', 'domain', 'url' ) VALUES ( ?, ?, ? );" ) or die $DBI::errstr;

	# open the given file
	open FILE, " < $file" or die "Can't open $file ($!)\n";

	# process each line in the file
	my $counter = 0;
	while ( <FILE> ) {

		# increment; skip the first line
		$counter++;
		next if ( $counter == 1 );
	
		# parse, escape, and do the work
		chop;
		my ( $id, $domain, $url ) = split( "\t", $_ );
		$id     =~ s/'/''/g;
		$domain =~ s/'/''/g;
		$url    =~ s/'/''/g;
		$sth->execute( $id, $domain, $url ) or die $DBI::errstr;

	}
	
	# close the database
	$sth = $dbh->prepare( "END TRANSACTION;" ) or die $DBI::errstr;
	$sth->execute or die $DBI::errstr;

 }

sub adr {

	# get input
	my $dbh  = shift;
	my $file = shift;
	
	# prepare the database
	my $sth = $dbh->prepare( "BEGIN TRANSACTION;" ) or die $DBI::errstr;
	$sth->execute or die $DBI::errstr;
	$sth = $dbh->prepare( "INSERT INTO adr ( 'id', 'address' ) VALUES ( ?, ? );" ) or die $DBI::errstr;

	# open the given file
	open FILE, " < $file" or die "Can't open $file ($!)\n";

	# process each line in the file
	my $counter = 0;
	while ( <FILE> ) {

		# increment; skip the first line
		$counter++;
		next if ( $counter == 1 );
	
		# parse, escape, and do the work
		chop;
		my ( $id, $address ) = split( "\t", $_ );
		$id      =~ s/'/''/g;
		$address =~ s/'/''/g;
		$sth->execute( $id, $address ) or die $DBI::errstr;

	}
	
	# close the database
	$sth = $dbh->prepare( "END TRANSACTION;" ) or die $DBI::errstr;
	$sth->execute or die $DBI::errstr;

 }

sub pos {

	# get input
	my $dbh  = shift;
	my $file = shift;
	
	# prepare the database
	my $sth = $dbh->prepare( "BEGIN TRANSACTION;" ) or die $DBI::errstr;
	$sth->execute or die $DBI::errstr;
	$sth = $dbh->prepare( "INSERT INTO pos ( 'id', 'sid', 'tid', 'token', 'lemma', 'pos' ) VALUES ( ?, ?, ?, ?, ?, ? );" ) or die $DBI::errstr;

	# open the given file
	open FILE, " < $file" or die "Can't open $file ($!)\n";

	# process each line in the file
	my $counter = 0;
	while ( <FILE> ) {

		# increment; skip the first line
		$counter++;
		next if ( $counter == 1 );
	
		# parse, escape, and do the work
		chop;
		my ( $id, $sid, $tid, $token, $lemma, $pos ) = split( "\t", $_ );
		$token =~ s/'/''/g;
		$lemma =~ s/'/''/g;
		$sth->execute( $id, $sid, $tid, $token, $lemma, $pos ) or die $DBI::errstr;

	}
	
	# close the database
	$sth = $dbh->prepare( "END TRANSACTION;" ) or die $DBI::errstr;
	$sth->execute or die $DBI::errstr;

 }


sub ent {

	# get input
	my $dbh  = shift;
	my $file = shift;
	
	# prepare the database
	my $sth = $dbh->prepare( "BEGIN TRANSACTION;" ) or die $DBI::errstr;
	$sth->execute or die $DBI::errstr;
	$sth = $dbh->prepare( "INSERT INTO ent ( 'id', 'sid', 'eid', 'entity', 'type' ) VALUES ( ?, ?, ?, ?, ? );" ) or die $DBI::errstr;

	# open the given file
	open FILE, " < $file" or die "Can't open $file ($!). Call Eric.\n";

	# process each line in the file
	my $counter = 0;
	while ( <FILE> ) {

		# increment; skip the first line
		$counter++;
		next if ( $counter == 1 );
	
		# parse, escape, and do the work
		chop;
		my ( $id, $sid, $eid, $entity, $type ) = split( "\t", $_ );
		$entity =~ s/'/''/g;
		$sth->execute( $id, $sid, $eid, $entity, $type ) or die $DBI::errstr;

	}
	
	# close the database
	$sth = $dbh->prepare( "END TRANSACTION;" ) or die $DBI::errstr;
	$sth->execute or die $DBI::errstr;

 }






