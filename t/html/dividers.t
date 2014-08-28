#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;
use Test::More;
use Text::CaffeinatedMarkup::HTML;

plan tests => 1;

	my $parser = Text::CaffeinatedMarkup::HTML->new;

	test_divider();

done_testing();

# ------------------------------------------------------------------------------

sub test_divider {
	subtest 'Divider' => sub {
		plan tests => 1;
		is $parser->do( '~~' ),
		   '<hr>',
		   'basic divider';
	};
}

# ------------------------------------------------------------------------------