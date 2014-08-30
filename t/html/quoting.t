#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;
use Test::More;
use Text::CaffeinatedMarkup::HTML;

plan tests => 1;

	my $parser = Text::CaffeinatedMarkup::HTML->new;

	test_block_quoting();

done_testing();

# ------------------------------------------------------------------------------

sub test_block_quoting {
	subtest 'Block Quoting' => sub {
		plan tests => 1;

		subtest 'Single line block quote' => sub {
			plan tests => 1;
			is $parser->do(qq|  ""Single quote""|),
			   q|<blockquote class="cml-blockquote"><p>Single quote</p></blockquote>|,
			   'single line block quote with text';
		};

	};
}

# ------------------------------------------------------------------------------