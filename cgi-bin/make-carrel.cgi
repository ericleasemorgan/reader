#!/usr/bin/perl

# make-carrel.cgi - given various types of input, create a Distant Reader Study Carrel

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, distributed under a GNU Public License

# July 20, 2018 - first investigations; difficult, really!
# July 22, 2018 - started adding ability to use file uploads


# configure
use constant TEMPLATE => 'ssh crcfe "source /etc/profile; local/reader/bin/##CMD## ##INPUT## &> /dev/null &"';
use constant CMDS     => ( 'url2carrel' => 'url2carrel.sh', 'file2carrel' => 'file2carrel.sh', 'zotero2carrel' => 'zotero2carrel.sh' );
use constant TMP      => '/afs/crc.nd.edu/user/e/emorgan/local/reader/tmp';

# require
use CGI;
use CGI::Carp qw( fatalsToBrowser );
use File::Basename;
use File::Copy;	
use strict;

# initialize
my $cgi  = CGI->new;
my $cmd  = $cgi->param( 'cmd' );
my %cmds = CMDS;
my $ssh  = TEMPLATE;

# start to build the ssh command
$ssh =~ s/##CMD##/$cmds{ $cmd }/e;
	
# from url
if ( $cmd eq 'url2carrel' ) {

	# check for input and continue to build ssh command
	my $input = $cgi->param( 'input' );
	if ( ! $input ) { &error( "No value for input supplied. Call Eric." ) }
	$ssh =~ s/##INPUT##/$input/e;

}

# from single file
elsif ( $cmd eq 'file2carrel' ) {

	# check for input
	my $input = $cgi->param( 'input' );
	if ( ! $input ) { &error( "No value for input supplied. Call Eric." ) }
	
	# get the name of the temporary file, and move it to tmp; a bit ugly
	my ( $name, $path, $suffix ) = fileparse( $input, qr/\.[^.]*/ );	
	my $file     = $cgi->tmpFileName( $input );
	my $basename = fileparse( $file );
	my $new      = "$basename$suffix";
	copy( $file, TMP . "/$new" ) or &error( "Copy failed ($!). Call Eric." );
	
	# finish building the ssh command
	$ssh =~ s/##INPUT##/$new/e;

}

# from zotero file
elsif ( $cmd eq 'zotero2carrel' ) {
	
	# check for input
	my $input = $cgi->param( 'input' );
	if ( ! $input ) { &error( "No value for input supplied. Call Eric." ) }
	
	# get the name of the temporary file, and move it to tmp; a bit ugly
	my ( $name, $path, $suffix ) = fileparse( $input, qr/\.[^.]*/ );	
	my $file     = $cgi->tmpFileName( $input );
	my $basename = fileparse( $file );
	my $new      = "$basename$suffix";
	copy( $file, TMP . "/$new" ) or &error( "Copy failed ($!). Call Eric." );
	
	# finish building the ssh command
	$ssh =~ s/##INPUT##/$new/e;

}

# error
else { &error( "Unknown value for cmd ($cmd). Call Eric." ) }

# echo next steps
print $cgi->header;
print "<html><head><title></title></head><body style='text-align: center; margin: 10%'><p>$ssh</p></body></html>\n";

# do the work
system( $ssh );
exit;


sub error {

	my $message = shift;
	
	print $cgi->header;
	print "<html><head><title>Error</title></head><body style='margin: 10%; text-align: center'><p>Error: $message</p></body></html>\n";
	exit;

}

