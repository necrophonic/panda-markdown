#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;
use Test::More;
use Text::CaffeinatedMarkup::HTML;

plan tests => 3;

	my $parser = Text::CaffeinatedMarkup::HTML->new;

	test_link_with_alt();
	test_link_no_alt();
	test_link_in_text();

done_testing();

# ------------------------------------------------------------------------------

sub test_link_with_alt {
	subtest 'Links with alt text' => sub {
		plan tests => 2;
		is $parser->do( '[[http://example.com|my site]]' ),
		   '<p><a href="http://example.com">my site</a></p>',
		   'link with alt #1';

		is $parser->do( '[[https://example.com/one/two|my site]]' ),
		   '<p><a href="https://example.com/one/two">my site</a></p>',
		   'link with alt #2';
	};
}

# ------------------------------------------------------------------------------

sub test_link_no_alt {
	subtest 'Links with no alt text' => sub {
		plan tests => 2;
		is $parser->do( '[[http://example.com]]' ),
		   '<p><a href="http://example.com">http://example.com</a></p>',
		   'link with no alt #1';

		is $parser->do( '[[https://example.com/one/two]]' ),
		   '<p><a href="https://example.com/one/two">https://example.com/one/two</a></p>',
		   'link with no alt #2';
	};
}

# ------------------------------------------------------------------------------

sub test_link_in_text {
	subtest 'Links in text' => sub {
		plan tests => 1;
		is $parser->do( 'Go here [[http://example.com|a]] its great!' ),
		   '<p>Go here <a href="http://example.com">a</a> its great!</p>',
		   'basic link in text';
	};
}

# ------------------------------------------------------------------------------