#!/usr/bin/perl
use strict;

use Test::More;

use lib 't/lib';
use Helpers;

use Log::Declare;
use Text::CaffeinatedMarkup::PullParser;

plan tests => 2;

    can_ok 'Text::CaffeinatedMarkup::PullParser', qw|handle_text|;

    my $pp = Text::CaffeinatedMarkup::PullParser->new;

    test_text();

done_testing();

# ------------------------------------------------------------------------------

sub test_text {
    subtest 'test text' => sub {
        plan tests => 2;
        $pp->tokenize('This is some text');
		test_expected_tokens_list( $pp->tokens, [qw|text|] );
        is $pp->tokens->[0]->content, 'This is some text', 'content as expected';
    };
}
