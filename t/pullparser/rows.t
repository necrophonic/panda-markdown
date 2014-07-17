#!/usr/bin/perl
use strict;

use Test::More;

use lib 't/lib';
use Helpers;

use Log::Declare;
use Text::CaffeinatedMarkup::PullParser;

plan tests => 5;

    can_ok 'Text::CaffeinatedMarkup::PullParser', qw|handle_row handle_columndivider|;

    my $pp = Text::CaffeinatedMarkup::PullParser->new;

    test_simple_rows_and_columns();
    test_simple_rows_and_columns_at_start_of_parse();
    test_extended_markup_lines();
    test_simple_markup_in_column();

done_testing();

# ------------------------------------------------------------------------------

sub test_simple_rows_and_columns {
	subtest 'test simple rows and columns' => sub {
        plan tests => 1;

$pp->tokenize(<<EOT
Before row
==
First column
--
Second column
--
Third Column
==
After row
EOT
);
		test_expected_tokens_list(
			$pp->tokens, [qw|text row text column_divider text column_divider text row text line_break|]
		);
	};
}

# ------------------------------------------------------------------------------

sub test_simple_rows_and_columns_at_start_of_parse {
    subtest 'test simple rows and columns at start of parse' => sub {
        plan tests => 1;
        $pp->tokenize("==\nSomething\n==");
        test_expected_tokens_list( $pp->tokens, [qw|row text row|] );
    };
}

# ------------------------------------------------------------------------------

sub test_extended_markup_lines {
    subtest 'test extended markup lines' => sub {
        plan tests => 2;

$pp->tokenize(<<EOT
Before row
=============================
A column
--Then junk!!!
Second column
========ABC
EOT
);
		test_expected_tokens_list(
			$pp->tokens, [qw|text row text column_divider text row|]
		);
        is $pp->tokens->[2]->content, 'A column', 'text sample ok';
    };
}

# ------------------------------------------------------------------------------

sub test_simple_markup_in_column {
    subtest 'test simple markup in column' => sub {
        plan tests => 2;

$pp->tokenize(<<EOT
==
**Important!** and something trivial
--
**More Important!**
==
EOT
);
    
		test_expected_tokens_list(
			$pp->tokens, [qw|row emphasis text emphasis text column_divider emphasis text emphasis row|]
		);
        is $pp->tokens->[2]->content, 'Important!', 'text sample ok';
    };
}
