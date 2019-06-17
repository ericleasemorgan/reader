#!/usr/bin/env perl

use constant QUERY => '../../bin/query.sh';

# require
use strict;

# initialize
my $query   = QUERY;
my @madlibs = ();

# read all madlibs
while ( <DATA> ) {
	chop;
	push( @madlibs, $_ );
}

# randomly choose a madlib
my $madlib = $madlibs[ rand @madlibs ];

# process each token in the given madlib
while ( $madlib =~ m/(##.*?##)/ ) {

	# re-initialize
	my $pattern = '';
	my $pos     = '';
	my $word    = '';
	my $sql     = "SELECT token FROM pos WHERE pos IS '##POS##' ORDER BY RANDOM() LIMIT 1;";
	
	# re-configure
	$pattern =  $1;
	$pos     =  $pattern;
	$pos     =~ s/#//g;
	$sql     =~ s/##POS##/$pos/e;
	$word    =  lc( `$query "$sql"` );
	chop( $word );
		
	# do the work
	$madlib  =~ s/$pattern/$word/e;
	
}

# output and done
print "$madlib\n\n";
exit;

__DATA__
A good wine, served ##RB##, can make any meal a truly ##JJ## occasion. The red wines have a/an ##JJ## flavor that blends with boiled ##NNS## or smoked ##NN##. White wines range in flavor from ##JJ## to ##JJ##. The best wines area made by peasants in ##PRP## from the juice of right ##NNS##, by putting them in vats and squashing them with their ##JJ## feet. This is what gives wine that ##JJ## aroma. Here are a few rules: 1) Always serve white wine with a/an ##JJ## glass at ##NN## temperature, 2) Never serve burgundy with fried ##NNS##, and 3) Wines should always be drunk ##RB## or your liable to end up with a/an ##JJ## stomach.
##PRP## has just written a book called "The ##NN## in the ##JJ## ##NN##." The main character in this ##JJ## story is a/an ##JJ## woman named ##PRP## who has just been elected president. She must decide whether to spend money on making ##JJ## bombs, sending people to the planet ##NN##, or building ##NN## to accomodate the growing population. The author creates many ##JJ## moment, and you will find yourself sitting on the edge of your ##NN## late at night because you cannot stop ##VBG## this book. ##PRP## turns out to be the greatest president in the last century and leads the people to peace and ##JJ##. This book is written ##RB## and should be nominated for a ##JJ## award.
