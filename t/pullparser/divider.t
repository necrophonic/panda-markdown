#!/usr/bin/perl
use strict;

use Test::More;

use lib 't/lib';
use Helpers;

use Log::Declare;
use Text::CaffeinatedMarkup::PullParser;

plan tests => 2;

    can_ok 'Text::CaffeinatedMarkup::PullParser', qw|handle_divider|;

    my $pp = Text::CaffeinatedMarkup::PullParser->new;

    test_divider();

done_testing();

# ------------------------------------------------------------------------------

sub test_divider {
    subtest 'test dividers' => sub {
    	plan tests => 2;
    	subtest 'normal divider' => sub {
			plan tests => 1;
			$pp->tokenize("~~");
			test_expected_tokens_list( $pp->tokens, [qw|divider|] );
		};

		subtest 'incomplete sequence' => sub {
			plan tests => 2;
			$pp->tokenize("~something");
			test_expected_tokens_list( $pp->tokens, [qw|text|] );
			is $pp->tokens->[0]->content, '~something', 'content is correct';
		};
	};
}
