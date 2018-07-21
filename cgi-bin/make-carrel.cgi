#!/usr/bin/perl

# make-carrel.cgi - given a various types of input, create a study carrel

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, distributed under a GNU Public License

# July 20, 2018 - first investigations; difficult, really!


# configure
use constant TEMPLATE => 'ssh crcfe "source /etc/profile; local/reader/bin/##CMD## ##INPUT## &> /dev/null &"';
use constant CMDS     => ( 'url2carrel' => 'url2carrel.sh', 'file2carrel' => 'file2carrel.sh' );

# require
use CGI;
use CGI::Carp qw( fatalsToBrowser );
use strict;

# initialize
my $cgi   = CGI->new;
my $cmd   = $cgi->param( 'cmd' );
my $input = $cgi->param( 'input' );
my %cmds  = CMDS;
my $ssh   = TEMPLATE;

# from url
if ( $cmd eq 'url2carrel' ) {

	# start to build the ssh command
	$ssh =~ s/##CMD##/$cmds{ $cmd }/e;
	
	# check for input and continue to build ssh command
	if ( ! $input ) { &error( "No value for input supplied. Call Eric." ) }
	$ssh =~ s/##INPUT##/$input/e;

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

