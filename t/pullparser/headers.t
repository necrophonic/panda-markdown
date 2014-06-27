#!/usr/bin/perl
use strict;

use Test::More;

use lib 't/lib';
use Helpers;

use Text::CaffeinatedMarkup::PullParser;

plan tests => 2;

    can_ok 'Text::CaffeinatedMarkup::PullParser', qw|handle_header|;

    my $pp = Text::CaffeinatedMarkup::PullParser->new;

    test_simple_headers();

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
