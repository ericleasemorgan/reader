#!/usr/bin/env perl

# html2urls.pl - given an html file, extract all of its links

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, distributed under a GNU Public License

# July 17, 2018 - first investigations


# require
use strict;
use HTML::LinkExtor;

# sanity check
my $file = $ARGV[ 0 ];
if ( ! $file ) { die "Usage: $0 <file>\n" }

# initialize
my $parser = HTML::LinkExtor->new;
my %urls   = ();

# parse a file
$parser->parse_file( $file );

# extract the links and loop through them
foreach my $link ( $parser->links ) {

    # parse the parsed
    my @elements = @$link;
    my $type    = shift @elements;
    
    # possibly test whether this is an element we're interested in

    while ( @elements ) {
    
        # extract the next attribute and its value
        my ( $name, $value ) = splice( @elements, 0, 2 );

        $urls{ $value }++;

    }
    
}

for ( sort keys %urls ) { print $_, "\n" }

