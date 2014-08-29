#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;
use Test::More;
use Text::CaffeinatedMarkup::Text;

plan tests => 1;

	my $parser = Text::CaffeinatedMarkup::Text->new;

	test_basic_text_with_emphasis();

done_testing();

# ------------------------------------------------------------------------------

sub test_basic_text_with_emphasis {
	subtest 'Basic text with emphasis' => sub {
		plan tests => 5;

		is $parser->do( 'The **quick** brown //foo//' ),
		   'The **quick** brown *foo*',
		   'plain text with emphasis';		

		is $parser->do( 'The **quick //brown// foo**' ),
		   'The **quick *brown* foo**',
		   'plain text with emphasis';

		is $parser->do( '--deleted--' ), '-deleted-', 'deleted text';
		is $parser->do( '++insert++' ),  '+insert+',  'inserted text';
		is $parser->do( '__under__' ),   '_under_',   'underlined text';
	};
}

# ------------------------------------------------------------------------------