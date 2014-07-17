#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;

use Test::More;
use Test::Exception;

plan tests => 7;

	use_ok 'Text::CaffeinatedMarkup::PullParser';
	can_ok 'Text::CaffeinatedMarkup::PullParser', qw|tokenize|;	

    my $pp = new_ok 'Text::CaffeinatedMarkup::PullParser';

    test_escaping();
    test_dividers();
    test_breaks();

    # Not public interface things, but stuff to verify
    # that the internals do what they should!
    test_peek();
	
done_testing;

# ------------------------------------------------------------------------------

sub test_peek {
    subtest 'Peek' => sub {
        plan tests => 3;

		dies_ok {
			my $pp = Text::CaffeinatedMarkup::PullParser->new(cml=>'');
			$pp->_set_chars([split//,'abc']);
			$pp->_set_pointer(2); # Set onto 'c'
			$pp->_peek;
		} 'dies when over peeking';

		lives_ok {
			my $pp = Text::CaffeinatedMarkup::PullParser->new(cml=>'');
			$pp->_set_chars([split//,'abc']);
			$pp->_set_pointer(1); # Set onto 'c'
			is $pp->_peek, 'c', 'peek at "c"';
		} 'live ok';
	};
}

# ------------------------------------------------------------------------------

sub test_escaping {
    subtest 'test escaping' => sub {
		plan tests => 3;
		$pp->tokenize('\**cat \***dog**');
		test_expected_tokens_list( $pp->tokens, [qw|text emphasis text emphasis|] );
		is $pp->tokens->[0]->content, '**cat *', 'content is correct';
		is $pp->tokens->[2]->content, 'dog',    'content is correct';
	};
}

# ------------------------------------------------------------------------------

sub test_dividers {
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

# ------------------------------------------------------------------------------


# Test the classes of returned tokens - doesn't test
# the content of any of the tokens.
sub test_expected_tokens_list {
	my ($tokens_got, $tokens_expected) = @_;

	subtest 'expect tokens' => sub {
		plan tests => scalar @$tokens_expected;

		for (my $i=0;$i<@$tokens_expected;$i++)	{

			my $camel_token = ucfirst $tokens_expected->[$i];
			   $camel_token =~ s/_(\w)/\u$1/g;

			my $expected_class = 'Text::CaffeinatedMarkup::PullParser::'.$camel_token.'Token';
			is ref $tokens_got->[$i], $expected_class, ref($tokens_got->[$i]) ." == $expected_class";
		}
	};
}

# -----------------------------------------------------------------------------
