#!/usr/bin/perl
use strict;

use Test::More;

use lib 't/lib';
use Helpers;

use Text::CaffeinatedMarkup::PullParser;

plan tests => 3;

    can_ok 'Text::CaffeinatedMarkup::PullParser', qw|handle_header|;

    my $pp = Text::CaffeinatedMarkup::PullParser->new;

    test_simple_headers();
    test_heading_after_break();

done_testing();

# ------------------------------------------------------------------------------

sub test_simple_headers {
	subtest 'test simple headers' => sub {
		plan tests => 6;
		$pp->tokenize('# Header');
		test_expected_tokens_list( $pp->tokens, [qw|header|] );
		is $pp->tokens->[0]->level, 1, 'level is correct (1)';		
		is $pp->tokens->[0]->content, 'Header', 'content is correct (1)';		

		$pp->tokenize('### Header');
		test_expected_tokens_list( $pp->tokens, [qw|header|] );
		is $pp->tokens->[0]->level, 3, 'level is correct (3)';
		is $pp->tokens->[0]->content, 'Header', 'content is correct (1)';		
	};
}

# ------------------------------------------------------------------------------

sub test_heading_after_break {
	subtest 'test heading after break' => sub {
		plan tests => 4;
		$pp->tokenize(qq|cracking.\n\n## Ahead warp factor 5!|);
		test_expected_tokens_list( $pp->tokens, [qw|text paragraph_break header|]);
		is $pp->tokens->[0]->content, 'cracking.', 'content is correct';
		is $pp->tokens->[2]->level, 2, 'level is correct (3)';
		is $pp->tokens->[2]->content, 'Ahead warp factor 5!', 'content is correct';
	};
}


