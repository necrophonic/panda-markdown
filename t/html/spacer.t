#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;
use Test::More;
use Text::CaffeinatedMarkup::HTML;

plan tests => 2;

	my $parser = Text::CaffeinatedMarkup::HTML->new;

	test_spacer();
	test_spacer_in_content();

done_testing();

# ------------------------------------------------------------------------------

sub test_spacer {
	subtest 'Basic spacers' => sub {
		plan tests => 2;
		is $parser->do( '^^' ),
		   '<div class="cml-spacer">&nbsp;</div>',
		   'single spacer';

		is $parser->do( "^^\n^^" ),
		   '<div class="cml-spacer">&nbsp;</div><div class="cml-spacer">&nbsp;</div>',
		   'multiple spacers';
	};
}

# ------------------------------------------------------------------------------

sub test_spacer_in_content {
	subtest 'Spacers inside content' => sub {
		plan tests => 1;
		is $parser->do( "This is some text\n^^\n^^\n^^\nThis is spaced down" ),
		   '<p>This is some text<div class="cml-spacer">&nbsp;</div><div class="cml-spacer">&nbsp;</div><div class="cml-spacer">&nbsp;</div>This is spaced down</p>',
		   'spacers inside a paragraph';
	};
}

# ------------------------------------------------------------------------------