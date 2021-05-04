#!/usr/bin/env perl

# carrel2zip.pl - given a directory name, zip it

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, distributed under a GNU Public License

# July 14, 2018 - first investigations


# configure
use constant READERCORD_HOME => $ENV{ 'READERCORD_HOME' };

use constant ETC     => 'etc';
use constant CARRELS =>  READERCORD_HOME . '/carrels';
use constant READER  => 'reader';

# require
use Archive::Zip;
use File::Basename;
use strict;

# sanity check
my $name = $ARGV[ 0 ];
if ( ! $name ) { die "Usage: $0 <name>\n" }

# initialize
my $etc     = ETC;
my $carrels = CARRELS;
my $reader  = READER;
my $zip     = Archive::Zip->new();

# do the work
$zip->addTree( "$carrels/$name", $name );
$zip->writeToFileNamed( "$carrels/$name/$etc/$reader.zip" );

# done
exit;


