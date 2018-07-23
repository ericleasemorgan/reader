#!/usr/bin/perl

# make-carrel.cgi - given various types of input, create a Distant Reader Study Carrel

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, distributed under a GNU Public License

# July 20, 2018 - first investigations; difficult, really!
# July 22, 2018 - started adding ability to use file uploads
# July 23, 2018 - added zotero and file of urls uploads; added email address


# configure
use constant TEMPLATE => 'ssh crcfe "source /etc/profile; local/reader/bin/##CMD## ##INPUT## ##ADDRESS## &> /dev/null &"';
use constant TMP      => '/afs/crc.nd.edu/user/e/emorgan/local/reader/tmp';
use constant CMDS     => ( 'url2carrel'    => 'url2carrel.sh',
                           'file2carrel'   => 'file2carrel.sh',
                           'zotero2carrel' => 'zotero2carrel.sh',
                           'urls2carrel'   => 'urls2carrel.sh' );

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

# start building the remote ssh command
$ssh =~ s/##CMD##/$cmds{ $cmd }/e;

# from url
if ( $cmd eq 'url2carrel' ) {

	# check for input and continue to build ssh command
	my $input = $cgi->param( 'input' );
	if ( ! $input ) { &error( "No value for input supplied. Call Eric." ) }
	$ssh =~ s/##INPUT##/$input/e;

}

# from various types of single files
elsif ( $cmd eq 'file2carrel' or $cmd eq 'zotero2carrel' or $cmd eq 'urls2carrel' ) {

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

# get and add the email address to the ssh command
my $address = $cgi->param( 'address' );
if ( ! $address ) { &error( "No value for email address supplied. Call Eric." ) }
$ssh =~ s/##ADDRESS##/$address/e;

# submit the work
system( $ssh );

# echo next steps and done
print $cgi->header;
print "<html><head><title>Distant Reader - Submission successful</title></head><body style='margin: 10%'><h1>Distant Reader - Submission successful</h1><p>Your submission was successfully submitted, and in a few minutes you ought to recieve an email message pointing you to the results. If you have any questions, then drop us a line, and thank you for using the Distant Reader.</p><hr /><p style='text-align:right'>Eric Lease Morgan &lt;<a href='mailto:emorgan\@nd.edu'>emorgan\@nd.edu</a>&gt;</p></body></html>\n";
exit;


sub error {

	my $message = shift;
	print $cgi->header;
	print "<html><head><title>Error</title></head><body style='margin: 10%; text-align: center'><p>Error: $message</p></body></html>\n";
	exit;

}





