#!/usr/bin/perl
use strict;

use Test::More;

use lib 't/lib';
use Helpers;

use Log::Declare;
use Text::CaffeinatedMarkup::PullParser;

plan tests => 2;

    my $pp = Text::CaffeinatedMarkup::PullParser->new;

    test_single_escape();
    test_block_escape();

done_testing();

# ------------------------------------------------------------------------------

sub test_single_escape {
    subtest 'test single escape' => sub {
        plan tests => 3;
		$pp->tokenize('\**cat \***dog**');
		test_expected_tokens_list( $pp->tokens, [qw|text emphasis text emphasis|] );
		is $pp->tokens->[0]->content, '**cat *', 'content is correct';
		is $pp->tokens->[2]->content, 'dog',     'content is correct';
    };
}

# ------------------------------------------------------------------------------

sub test_block_escape {
	subtest 'test block escape' => sub {
		plan tests => 1;

		$pp->tokenize('Something %%**escaped//[[%% then something');
		test_expected_tokens_list( $pp->tokens, [qw|text|]);

		is $pp->tokens->[0]->content,
		   'Something **escaped//[[ then something',
		   'content is correct';

	};
}