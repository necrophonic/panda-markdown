use v5.16;

use strict;
use warnings;
use boolean;

use Test::More;
use Test::Exception;

use PML;

use_ok "PML";

	can_ok( 'PML', 'markdown' );

	my $tag_map = PML::_type_to_tag;
	is_deeply(
		$tag_map,
		{HEAD1	=> 'h1',
		HEAD2	=> 'h2',
		HEAD3	=> 'h3',
		HEAD4	=> 'h4',
		HEAD5	=> 'h5',
		HEAD6	=> 'h6',
		STRONG		=> 'strong',
		EMPHASIS	=> 'em',
		UNDERLINE	=> 'u'}
	);

done_testing();
exit(0);
