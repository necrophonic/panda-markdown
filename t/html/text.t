#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;
use Test::More;
use Text::CaffeinatedMarkup::HTML;

plan tests => 1;

	my $parser = Text::CaffeinatedMarkup::HTML->new;

	test_basic_text();

done_testing();

# ------------------------------------------------------------------------------

sub test_basic_text {
	subtest 'Basic text' => sub {
		plan tests => 1;				
		my $html   = $parser->do( 'The quick brown foo' );
		is $html, '<p>The quick brown foo</p>', 'plain text';
	};
}

# ------------------------------------------------------------------------------