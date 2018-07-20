#!/usr/bin/perl

# file2carrel.cgi - given a file, create a study carrel

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, distributed under a GNU Public License

# July 20, 2018 - first investigations; difficult, really!


# configure
use constant SSHCMD => 'ssh crcfe "source /etc/profile; local/reader/bin/file2carrrel.sh position.pdf &> /dev/null &"';

# require
use CGI;
use CGI::Carp qw( fatalsToBrowser );
use strict;

# initialize
my $cgi = CGI->new;

# echo next steps
print $cgi->header;
print "<html><head><title></title></head><body style='text-align: center; margin: 10%'><h1>Hello, World!</h1></body></html>\n";

# do the work
system( SSHCMD );
exit;

