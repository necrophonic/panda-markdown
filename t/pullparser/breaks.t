#!/usr/bin/perl
use strict;

use Test::More;

use lib 't/lib';
use Helpers;

use Log::Declare;
use Text::CaffeinatedMarkup::PullParser;

plan tests => 2;

    can_ok 'Text::CaffeinatedMarkup::PullParser', qw|handle_linebreak handle_paragraphbreak|;

    my $pp = Text::CaffeinatedMarkup::PullParser->new;

    test_breaks();

done_testing();

# ------------------------------------------------------------------------------

sub test_breaks {
    subtest 'test breaks' => sub {
		plan tests => 6;

		$pp->tokenize("Text\nText after");
		test_expected_tokens_list( $pp->tokens, [qw|text line_break text|] );
		is $pp->tokens->[2]->content, 'Text after', 'text ok';

		$pp->tokenize("Text\n\nText after");
		test_expected_tokens_list( $pp->tokens, [qw|text paragraph_break text|] );

		$pp->tokenize("Text\n\n\n\n\nMore Text after");
		test_expected_tokens_list( $pp->tokens, [qw|text paragraph_break text|] );
		is $pp->tokens->[2]->content, 'More Text after', 'text ok';

        subtest 'supressed breaks' => sub {
    		$pp->tokenize("==\nCol\n--\nCol\n==");
	    	test_expected_tokens_list( $pp->tokens, [qw|row text column_divider text row|] );
        };
	};
}
