#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;
use Test::More;
use Text::CaffeinatedMarkup::HTML;

plan tests => 1;

	my $parser = Text::CaffeinatedMarkup::HTML->new;

	test_escaping();

done_testing();

# ------------------------------------------------------------------------------

sub test_escaping {
	subtest 'Escaping' => sub {
		plan tests => 2;

		subtest 'Escapes in simple text' => sub {
			is $parser->do(q|Some \**escaped\** %%text [[]]%%|),
			   q|<p>Some **escaped** text [[]]</p>|,
			   'simple single and block escape in text';
		};		

		subtest 'Escapes with newlines' => sub {
			is $parser->do(qq|Some \\**escaped\\**\n\%\%text\n\n[[]]\%\%|),
			   qq|<p>Some **escaped**<br>text\n\n[[]]</p>|,
			   'simple single and block escape in text with newlines';
		};		
	};
}

# ------------------------------------------------------------------------------