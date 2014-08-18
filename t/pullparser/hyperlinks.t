#!/usr/bin/perl
use strict;

use Test::More;

use lib 't/lib';
use Helpers;

use Text::CaffeinatedMarkup::PullParser;

plan tests => 4;

    can_ok 'Text::CaffeinatedMarkup::PullParser', qw|handle_link|;

    my $pp = Text::CaffeinatedMarkup::PullParser->new;

    test_hyperlink_with_alt_text();
    test_hyperlink_with_no_alt_text();
    test_hyperlink_at_start_of_parse();

done_testing();

# ------------------------------------------------------------------------------

sub test_hyperlink_with_alt_text {
    subtest 'test hyperlink with alt text' => sub {
    	plan tests => 3;
    	$pp->tokenize('Go here: [[http://www.example.com|example site]]');
    	test_expected_tokens_list( $pp->tokens, [qw|text link|] );
    	is $pp->tokens->[1]->href, 'http://www.example.com', 'href is correct';
    	is $pp->tokens->[1]->text, 'example site', 'text is correct';
    };
}  

# ------------------------------------------------------------------------------

sub test_hyperlink_with_no_alt_text {
    subtest 'test hyperlink with no alt text' => sub {
    	plan tests => 3;
    	$pp->tokenize('Go here: [[http://www.example.com]]');
    	test_expected_tokens_list( $pp->tokens, [qw|text link|] );
    	is $pp->tokens->[1]->href, 'http://www.example.com', 'href is correct';
    	is $pp->tokens->[1]->text, '', 'text is correct';
    };
}

# ------------------------------------------------------------------------------

sub test_hyperlink_at_start_of_parse {
    subtest 'test hyperlink at start of parse' => sub {
    	plan tests => 3;
    	$pp->tokenize('[[http://www.example.com]]');
    	test_expected_tokens_list( $pp->tokens, [qw|link|] );
    	is $pp->tokens->[0]->href, 'http://www.example.com', 'href is correct';
    	is $pp->tokens->[0]->text, '', 'text is correct';
    };   
}

# ------------------------------------------------------------------------------


