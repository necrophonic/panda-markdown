#!/usr/bin/perl
use strict;

use Test::More;

use lib 't/lib';
use Helpers;

use Text::CaffeinatedMarkup::PullParser;

plan tests => 2;

    can_ok 'Text::CaffeinatedMarkup::PullParser', qw|handle_spacer|;

    my $pp = Text::CaffeinatedMarkup::PullParser->new;

    test_spacer();

done_testing();

# ------------------------------------------------------------------------------

sub test_spacer {
	subtest 'test spacer' => sub {
  		plan tests => 4;
    		
    	$pp->tokenize('^^');
    	test_expected_tokens_list( $pp->tokens, [qw|spacer|] );

    	$pp->tokenize('^^^^^^^^^');
    	test_expected_tokens_list( $pp->tokens, [qw|spacer|] );

    	$pp->tokenize('^^^^ IGNORE THIS');
    	test_expected_tokens_list( $pp->tokens, [qw|spacer|] );

    	$pp->tokenize("^^\n^^\n^^");
    	test_expected_tokens_list( $pp->tokens, [qw|spacer spacer spacer|] );	
	};
}

# ------------------------------------------------------------------------------
