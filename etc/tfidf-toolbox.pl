# tfidf-toolbox.pl - a library of functions used to index, classify, and compare documents as well as rank search results

# Eric Lease Morgan <eric_morgan@infomotions.com>

# April   10, 2009 - first investigations
# April   11, 2009 - added stopwords; efficient-ized
# April   12, 2009 - added dynamic corpus
# April   16, 2009 - added dot product and Euclidian length
# April   17, 2009 - added compare
# April   25, 2009 - added great_idea
# May     31, 2009 - added cosine to compare routine, dumb!
# December 8, 2018 - added measurements for each idea


# measure tfidf scores for a given lexicon
sub measure {

	# get input
	my $index = shift;
	my $files = shift;
	my $ideas = shift;
	
	# initialize
	my %measurements = ();
	
	# process each file
	foreach $file ( @$files ) {
	
		my $words = $$index{ $file };
		my %ideas = ();
		
		# process each big idea
		foreach my $idea ( keys %$ideas ) {
		
			# get n and t for tdidf
			my $n = $$words{ $idea };
			my $t = 0;
			foreach my $word ( keys %$words ) { $t = $t + $$words{ $word } }
			
			# calculate; sum all tfidf scores for all ideas
			$ideas{ $idea } = &tfidf( $n, $t, scalar( keys %$index ), scalar @$files );
			
		}
	
		# build up the measurements
		$measurements{ $file } = \%ideas;
	}
	
	# done
	return \%measurements;
	
}


# score documents based on sets of keywords -- big names or great ideas
sub great_ideas {

	my $index = shift;
	my $files = shift;
	my $ideas = shift;
	
	my %coefficients = ();
	
	# process each file
	foreach $file ( @$files ) {
	
		my $words = $$index{ $file };
		my $coefficient = 0;
		
		# process each big idea
		foreach my $idea ( keys %$ideas ) {
		
			# get n and t for tdidf
			my $n = $$words{ $idea };
			my $t = 0;
			foreach my $word ( keys %$words ) { $t = $t + $$words{ $word } }
			
			# calculate; sum all tfidf scores for all ideas
			$coefficient = $coefficient + &tfidf( $n, $t, scalar( keys %$index ), scalar @$files );
		
		}
		
		# assign the coefficient to the file
		$coefficients{ $file } = $coefficient;
	
	}
	
	return \%coefficients;

}


# compare two documents for similarity
sub compare {

	my $books     = shift;
	my $stopwords = shift;
	my $ideas     = shift;
	my $directory = shift;

	my %index = ();
	my @a     = ();
	my @b     = ();
	
	# index
	foreach my $book ( @$books ) { $index{ $book } = &index( $book, $stopwords ) }
	
	# process each idea
	foreach my $idea ( sort( keys( %$ideas ))) {
	
		# search
		my ( $hits, @files ) = &search( \%index, $idea );
	
		# rank
		my $ranks = &rank( \%index, [ @files ], $idea, $directory );
	
		# build vectors, a & b
		my $index = 0;
		foreach my $file ( @$books ) {
		
			if    ( $index == 0 ) { push @a, $$ranks{ $file }}
			elsif ( $index == 1 ) { push @b, $$ranks{ $file }}
			$index++;
			
		}
		
	}

	# compare; scores closer to 1 approach similarity
	return ( ( &dot( [ @a ], [ @b ] ) / ( &euclidian( [ @a ] ) * &euclidian( [ @b ] ) ) ) );

}


# build the corpus, all ./*.txt files
sub corpus {

	my $directory = shift;
	my @corpus = ();
	
	opendir( CWD, $directory ) or die "Can't opendir ($directory): $!";
	while ( my $file = readdir( CWD )) {
	
		if ( $file =~ /\.txt$/ ) { push @corpus, $directory . '/' . $file }
		
	}
	
	closedir( CWD );
	return sort( @corpus );
	
}


# return a hash of all words in a document, plus their counts
sub index {

	my $file      = shift;
	my $stopwords = shift;
	
	my %words = ();
	
	open ( F, "< $file" ) or die "Can't open $file ($!)\n";
	while ( <F> ) {
	
		foreach my $word ( split /\s/ ) {
		
			# normalize and exclude words we don't want
			next if ( ! $word );
			$word = lc( $word );
			$word =~ s/^\W//;
			$word =~ s/\W$//;
			next if ( $word =~ /\d/ );
			next if ( length( $word ) < 3 );
			next if ( $$stopwords{ $word } );
			
			# update the "index"
			$words{ $word }++;
			
		}
		
	}
	
	close F;
	return \%words;

}


# return the number of hits against a corpus and a list of the corresponding files
sub search {

	my $index = shift;
	my $query = shift;
	
	my $hits  = 0;
	my @files = ();
	
	foreach ( keys %$index ) {
	
		my $words = $$index{ $_ };
		if ( $$words{ $query } ) {
		
			$hits++;
			push @files, $_;
			
		}
		
	}
	
	return ( $hits, @files );

}


# assign a rank to a given file for a given query
sub rank {
	
	my $index     = shift;
	my $files     = shift;
	my $query     = shift;
	my $directory = shift;
	
	my %ranks  = ();
	my @corpus = &corpus( $directory );
	
	foreach my $file ( @$files ) {
	
		# get n, query word count in a document
		my $words = $$index{ $file };
		my $n = $$words{ $query };
				
		# calculate t, total number of words in a document
		my $t = 0;
		foreach my $word ( keys %$words ) { $t = $t + $$words{ $word } }
		
		# assign tfidf to file	
		$ranks{ $file } = &tfidf( $n, $t, scalar( @corpus ), scalar @$files );

	}

	return \%ranks;

}


# rank each word in a given document compared to a corpus
sub classify {

	my $index  = shift;
	my $file   = shift;
	my $corpus = shift;
	
	my %tags = ();
	
	foreach my $words ( $$index{ $file } ) {
	
		# calculate t, total number of words in a document
		my $t = 0;
		foreach my $word ( keys %$words ) { $t = $t + $$words{ $word } }
		
		foreach my $word ( keys %$words ) {
	
			# get n, query word count in a document
			my $n = $$words{ $word };
			
			# calculate h, number of hits across the corpus
			my ( $h, @files ) = &search( $index, $word );

			# assign tfidf to word
			$tags{ $word } = &tfidf( $n, $t, scalar @$corpus, $h );
			
		}
				
	}
	
	return \%tags;
	
}


# calculate tfidf
sub tfidf {

	# tfidf = ( n / t ) * log( d / h ) where:
	#     n = number of times a word appears in a document
	#     t = total number of words
	#     d = total number of documents
	#     h = number of documents that contain the word

	my $n = shift;
	my $t = shift;
	my $d = shift;
	my $h = shift;
	
	my $tfidf = 0;
	
	if ( $d == $h ) { $tfidf = ( $n / $t ) }
	else { $tfidf = ( $n / $t ) * log( $d / $h ) }
	
	return $tfidf;
	
}


# slurp up stopwords
sub slurp_words {

	my $file = shift;
	
	my %words = ();
	
	open ( S, " < $file" ) or die "Can't open $file ($!)\n";
	while ( <S> ) {
	
		chop;
		next if ( ! $_ );  # blank line
		next if ( /^#/ );  # comments
		$words{ $_ }++;
		
	}
	
	close S;
	return \%words;

}


sub euclidian {

	# Euclidian length = sqrt( a1^2 + a2^2 ... ) where a is an array (vector)
	my $a = shift;
	my $e = 0;
	for ( my $i = 0; $i <= $#$a; $i++ ) { $e = $e + ( $$a[ $i ] * $$a[ $i ] ) }
	return sqrt( $e );

}


sub dot {

	# dot product = (a1*b1 + a2*b2 ... ) where a and b are equally sized arrays (vectors)
	my $a = shift;
	my $b = shift;
	my $d = 0;
	for ( my $i = 0; $i <= $#$a; $i++ ) { $d = $d + ( $$a[ $i ] * $$b[ $i ] ) }
	return $d;
  
}


# return true or die
return 1; 
