#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;
use Test::More;
use Text::CaffeinatedMarkup::Text;

plan tests => 1;

	my $parser = Text::CaffeinatedMarkup::Text->new;

	test_basic_text();

done_testing();

# ------------------------------------------------------------------------------

sub test_basic_text {
	subtest 'Basic text' => sub {
		plan tests => 1;				
		my $text   = $parser->do( 'The quick brown foo' );
		is $text, 'The quick brown foo', 'plain text';
	};
}

# ------------------------------------------------------------------------------