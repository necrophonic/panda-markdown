#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;
use Test::More;
use Text::CaffeinatedMarkup::HTML;

plan tests => 1;

	my $parser = Text::CaffeinatedMarkup::HTML->new;

	test_basic_text_with_emphasis();

done_testing();

# ------------------------------------------------------------------------------

sub test_basic_text_with_emphasis {
	subtest 'Basic text with emphasis' => sub {
		plan tests => 2;
		
		is $parser->do( 'The **quick** brown //foo//' ),
		   '<p>The <strong>quick</strong> brown <em>foo</em></p>',
		   'plain text with emphasis';		

		is $parser->do( 'The **quick //brown// foo**' ),
		   '<p>The <strong>quick <em>brown</em> foo</strong></p>',
		   'plain text with emphasis';		
	};
}

# ------------------------------------------------------------------------------