#!/usr/bin/perl
use strict;

use Test::More;

use lib 't/lib';
use Helpers;

use Text::CaffeinatedMarkup::PullParser;

plan tests => 2;

    my $pp = Text::CaffeinatedMarkup::PullParser->new;
    
    # TODO can_ok

    test_rows_and_columns();

done_testing();

# ------------------------------------------------------------------------------

sub test_rows_and_columns {
	subtest 'test rows and columns' => sub {

		my $cml = <<EOT
Before row
==
First column||Second column
||Third Column\\||Not a new column
==
After row
EOT
;
		$pp->tokenize($cml);

		error "%s",d:$pp->tokens;

		test_expected_tokens_list(
			$pp->tokens, [qw|text row_start text column_divider text column_divider text row_end text line_break|]
		);
	};
}

# ------------------------------------------------------------------------------

