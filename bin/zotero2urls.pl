#!/afs/crc.nd.edu/user/e/emorgan/bin/perl

# zotero2urls.pl - given a Zotero RDF file name, output a list of urls

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 16, 2018 - first cut


# require
use strict;
use XML::XPath;

# sanity check
my $file = $ARGV[ 0 ];
if ( ! $file ) { die "Usage: $0 <file>\n" }

# initialize
my $parser = XML::XPath->new( filename => $file );

# find and loop through all documents
foreach my $document ( $parser->find( '/rdf:RDF/bib:Document' )->get_nodelist ) {
    
    # output their urls
    print $document->find( './@rdf:about' ), "\n";
    
}

# done
exit;
