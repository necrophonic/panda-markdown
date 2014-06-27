#!/usr/bin/perl
use strict;

use Test::More;

use lib 't/lib';
use Helpers;

use Text::CaffeinatedMarkup::PullParser;

plan tests => 2;

    my $pp = Text::CaffeinatedMarkup::PullParser->new;

    test_simple_mixed_emphasis();
    test_emphasis_at_start_of_parse();

done_testing();

# ------------------------------------------------------------------------------

sub test_simple_mixed_emphasis {
    subtest 'test simple mixed emphasis' => sub {
        plan tests => 5;
    	$pp->tokenize('The **cat** sat __on__ the //mat//');
    	test_expected_tokens_list(
    		$pp->tokens,
    		[qw|text emphasis text emphasis text emphasis text emphasis text emphasis text emphasis|]
    	);
    	# Check the content of some tokens
    	is $pp->tokens->[0]->content, 'The ';
    	is $pp->tokens->[1]->type,    'strong';
    	is $pp->tokens->[5]->type,    'underline';
    	is $pp->tokens->[9]->type,    'emphasis';
    };
}

# ------------------------------------------------------------------------------

sub test_emphasis_at_start_of_parse {
    subtest 'Emphasis at start of parse' => sub {
    	plan tests => 4;
        $pp->tokenize('**Yay!**');
    	test_expected_tokens_list( $pp->tokens, [qw|emphasis text emphasis|] );
    	is $pp->tokens->[1]->content, 'Yay!';
    	is $pp->tokens->[0]->type,    'strong';
    	is $pp->tokens->[2]->type,    'strong';
    };
}

# ------------------------------------------------------------------------------

