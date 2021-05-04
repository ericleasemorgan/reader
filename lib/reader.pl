
sub make_absolute {

	# get input
	my $html = shift;
	my $base = shift;
	
	# do the work
	$html    =~ s/<(.*?)(href|src|action|background)\s*=\s*("|'?)(.*?)\3((\s+.*?)*)>/"<".$1.$2."=\"".URI->new_abs($4,$base)->as_string."\"".$5.">"/eigs;
	
	# done
	return( $html );
	
}


sub make_filename {

	# get (lot's of) input
	my $url       = shift;
	my $path      = shift;
	my $extension = shift;
	
	# return a filename
	my $host     =  lc( URI->new( $url )->host );
	$host        =~ s/\./-/g;
	return( $path . '/' . $host . '-' . int(rand(10000)) . ".$extension" );

}


sub extract_links {

	use HTML::LinkExtor;
	my $file = shift;
	my @urls = ();
	
	my $parser = HTML::LinkExtor->new;
	$parser->parse_file( $file );
	my %urls = ();

	foreach my $links ( $parser->links ) {

		my @elements = @$links;
		my $type     = shift @elements;
		while ( @elements ) {
	
			my ( $name , $value ) = splice( @elements, 0, 2 );
			$urls{ $value }++;
		
		}
	
	}

	for (sort keys %urls) { push( @urls, $_ ) }
	return( @urls );
	
}

# return true or die
return 1;
