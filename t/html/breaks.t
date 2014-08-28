#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;
use Test::More;
use Text::CaffeinatedMarkup::HTML;

plan tests => 2;

	my $parser = Text::CaffeinatedMarkup::HTML->new;

	test_line_breaks();
	test_paragraph_breaks();

done_testing();

# ------------------------------------------------------------------------------

sub test_line_breaks {
	subtest 'Line Breaks' => sub {
		plan tests => 1;
		is $parser->do(qq|Something\nAfter break|),
		   q|<p>Something<br>After break</p>|,
		   'single break in paragraph';
	};
}

# ------------------------------------------------------------------------------

sub test_paragraph_breaks {
	subtest 'Paragraph Breaks' => sub {
		plan tests => 3;
		is $parser->do(qq|Something\n\nAfter break|),
		   q|<p>Something</p><p>After break</p>|,
		   'single paragraph break';

		is $parser->do(qq|Something\n\n\n\n\nAfter break|),
		   q|<p>Something</p><p>After break</p>|,
		   'elongated paragraph break (multiple collapse to single)';

		is $parser->do(qq|Something\nMore\n\nAfter break|),
		   q|<p>Something<br>More</p><p>After break</p>|,
		   'break and paragraph';
	};
}

# ------------------------------------------------------------------------------