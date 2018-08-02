#!/usr/bin/perl

# request2queue.cgi - given various types of input, update a queue of work to do

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, distributed under a GNU Public License

# July 28, 2018 - first investigations; "Thanks, Doug Thain!"
# July 29, 2018 - hacking, just for relaxing fun
# July 30, 2018 - working but not pretty


# configure
use constant DRIVER   => 'SQLite';
use constant DATABASE => '../etc/library.db';
use constant MAKENAME => '../bin/make-name.sh';
use constant TMP      => '/afs/crc.nd.edu/user/e/emorgan/local/html/reader/tmp';
use constant CMDS     => ( 'url2carrel' => 1, 'file2carrel' => 1, 'zotero2carrel' => 1, 'urls2carrel' => 1 );
use constant STATUS   => 'queued';
use constant NOTE     => 'So far, so good.';


# require
use CGI;
use CGI::Carp qw( fatalsToBrowser );
use DateTime;
use DBI;
use File::Basename;
use File::Copy;	
use strict;

# initialize
my %cmds      = CMDS;
my $cgi       = CGI->new;
my $database  = DATABASE;
my $driver    = DRIVER;
my $make_name = MAKENAME;
my $status    = STATUS;
my $note      = NOTE;
my $dbh       = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
my $sth       = $dbh->prepare( "INSERT INTO acquisitions ( 'date_created', 'process', 'data', 'key', 'email', 'ip', 'date_updated', 'status', 'note' ) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ? );" ) or die $DBI::errstr;

# get/create values for the database table; get now
my $now = DateTime->now->datetime( ' ' );

# process
my $cmd = $cgi->param( 'cmd' );
if ( ! $cmds{ $cmd } ) { &error( "Unknown value for cmd ($cmd). Call Eric." ) };
my $process = $cgi->param( 'cmd' );

# data
my $data  = '';
my $input = $cgi->param( 'input' );
if    ( ! $input ) { &error( "No value for input supplied. Call Eric." ) }
if    ( $process eq 'url2carrel' ) { $data = $input }
elsif ( $process eq 'file2carrel' or $process eq 'zotero2carrel' or $process eq 'urls2carrel' ) {
	
	# get the name of the temporary file, and move it to tmp; a bit ugly
	my ( $name, $path, $suffix ) = fileparse( $input, qr/\.[^.]*/ );	
	my $file     = $cgi->tmpFileName( $input );
	my $basename = fileparse( $file );
	$data        = "$basename$suffix";
	copy( $file, TMP . "/$data" ) or &error( "Copy failed ($!). Call Eric." );
	
}

# key, email, and ip address
my $key   = `$make_name`;
my $email = $cgi->param( 'address' ); if ( ! $email ) { &error( "No value for email address supplied. Call Eric." ) }
my $ip    = $ENV{ REMOTE_ADDR };

# do the work; update the database
$sth->execute( $now, $cmd, $data, $key, $email, $ip, $now, $status, $note ) or die $DBI::errstr;
$dbh->disconnect;

# echo next steps and done
print $cgi->header;
print "<html><head><title>Distant Reader - Submission successful</title></head><body style='margin: 10%'><h1>Distant Reader - Submission successful</h1><p>Your submission was successfully submitted, and your special 7-character key is $key.</p></body></html>\n";
exit;


sub error {

	my $message = shift;
	print $cgi->header;
	print "<html><head><title>Error</title></head><body style='margin: 10%; text-align: center'><p>Error: $message</p></body></html>\n";
	exit;

}





