#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;
use Test::More;
use Text::CaffeinatedMarkup::HTML;

plan tests => 1;

	my $parser = Text::CaffeinatedMarkup::HTML->new;

	test_headers();

done_testing();

# ------------------------------------------------------------------------------

sub test_headers {
	subtest 'Headers' => sub {
		plan tests => 3;
		is $parser->do( '# My Header' ),
		   '<h1>My Header</h1>',
		   'level one header';

		is $parser->do( '#### My Header' ),
		   '<h4>My Header</h4>',
		   'level four header';

		is $parser->do( qq|Text\n\n## My Header| ),
		   '<p>Text</p><h2>My Header</h2>',
		   'header after break';
	};
}

# ------------------------------------------------------------------------------