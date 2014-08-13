#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;

use Test::More;
use Test::Exception;

plan tests => 4;

	use_ok 'Text::CaffeinatedMarkup::PullParser';
	can_ok 'Text::CaffeinatedMarkup::PullParser', qw|tokenize|;	

    my $pp = new_ok 'Text::CaffeinatedMarkup::PullParser';

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
