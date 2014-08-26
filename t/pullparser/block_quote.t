#!/usr/bin/perl
use strict;

use Test::More;

use lib 't/lib';
use Helpers;

use Log::Declare;
use Text::CaffeinatedMarkup::PullParser;

plan tests => 2;

    can_ok 'Text::CaffeinatedMarkup::PullParser', qw|handle_blockquote|;

    my $pp = Text::CaffeinatedMarkup::PullParser->new;

    test_blockquote_no_cite();
    #test_blockquote_with_cite();

done_testing();

# ------------------------------------------------------------------------------

sub test_blockquote_no_cite {
    subtest 'test blockquote without cite' => sub {
        plan tests => 10;
        $pp->tokenize('  ""This is a single line quote""');
		test_expected_tokens_list( $pp->tokens, [qw|block_quote text block_quote|] );
        is $pp->tokens->[1]->content, 'This is a single line quote', 'content as expected';

        $pp->tokenize(qq|  ""This is a dual\n  line quote""|);
        test_expected_tokens_list( $pp->tokens, [qw|block_quote text line_break text block_quote|] );
        is $pp->tokens->[1]->content, 'This is a dual', 'content as expected';
        is $pp->tokens->[3]->content, 'line quote', 'content as expected';

        $pp->tokenize(qq|==\n  ""This is a single line quote in a row""\n==|);
		test_expected_tokens_list( $pp->tokens, [qw|row block_quote text block_quote row|] );
        is $pp->tokens->[2]->content, 'This is a single line quote in a row', 'content as expected';

        $pp->tokenize('  ""This is a single line quote **with emphasis**""');
		test_expected_tokens_list( $pp->tokens, [qw|block_quote text emphasis text emphasis block_quote|] );
        is $pp->tokens->[1]->content, 'This is a single line quote ', 'content as expected';
        is $pp->tokens->[3]->content, 'with emphasis', 'content as expected';
    };
}

sub test_blockquote_with_cite {
	subtest 'test blockquote with cite' => sub {
		$pp->tokenize(qq|  ""This is a single line quote""\n  -- with cite|);
		test_expected_tokens_list( $pp->tokens, [qw|block_quote text block_quote|] );
        is $pp->tokens->[1]->content, 'This is a single line quote', 'content as expected';
	};
}