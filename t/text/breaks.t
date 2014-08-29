#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;
use Test::More;
use Text::CaffeinatedMarkup::Text;

plan tests => 2;

	my $parser = Text::CaffeinatedMarkup::Text->new;

	test_line_breaks();
	test_paragraph_breaks();

done_testing();

# ------------------------------------------------------------------------------

sub test_line_breaks {
	subtest 'Line Breaks' => sub {
		plan tests => 1;

		is $parser->do( "Line1\nLine2\nLine3" ),
		   "Line1\nLine2\nLine3",
		   'single line breaks';		
	};
}

# ------------------------------------------------------------------------------

sub test_paragraph_breaks {
	subtest 'Paragraph Breaks' => sub {
		plan tests => 1;

		is $parser->do( "Line1\n\nLine2\n\n\nLine3" ),
		   "Line1\n\nLine2\n\nLine3",
		   'paragraph breaks';		
	};
}

# ------------------------------------------------------------------------------