#!/usr/bin/perl
use strict;

use Test::More;

use lib 't/lib';
use Helpers;

use Log::Declare;
use Text::CaffeinatedMarkup::PullParser;

plan tests => 5;

    can_ok 'Text::CaffeinatedMarkup::PullParser', qw|handle_listitem|;

    my $pp = Text::CaffeinatedMarkup::PullParser->new;

    test_simple_list();
    test_simple_list_with_emphasis();
    test_simple_list_multilevel();

    test_break_at_start_of_list();

done_testing();

# ------------------------------------------------------------------------------

sub test_simple_list {
	subtest 'test simple list' => sub {
        plan tests => 1;

$pp->tokenize(<<EOT
  - Item 1
  - Item 2
  - Item 3
EOT
);
		test_expected_tokens_list(
			$pp->tokens, [qw|list_item text list_item text list_item text line_break|]
		);
	};
}

# ------------------------------------------------------------------------------

sub test_simple_list_with_emphasis {
  subtest 'test simple list' => sub {
        plan tests => 1;

$pp->tokenize(<<EOT
  - Item 1
  - **Emphasised Item 2**
  - **Item** 3
EOT
);
    test_expected_tokens_list(
      $pp->tokens, [qw|list_item text list_item emphasis text emphasis list_item emphasis text emphasis text line_break|]
    );
  };
}

# ------------------------------------------------------------------------------

sub test_simple_list_multilevel {
    subtest 'test simple list' => sub {
        plan tests => 5;

$pp->tokenize(<<EOT
  - Item 1
    - Item 2
  - Item 3
      - Item 4
EOT
);
        test_expected_tokens_list(
            $pp->tokens, [qw|list_item text list_item text list_item text list_item text line_break|]
        );
        is $pp->tokens->[0]->level, 2, 'correct level (2)';
        is $pp->tokens->[2]->level, 4, 'correct level (4)';
        is $pp->tokens->[4]->level, 2, 'correct level (2)';
        is $pp->tokens->[6]->level, 6, 'correct level (6)';
    };
}

# ------------------------------------------------------------------------------

sub test_break_at_start_of_list {
  subtest 'test simple list' => sub {
        plan tests => 1;

$pp->tokenize(<<EOT

  - Item 1  
EOT
);
    test_expected_tokens_list(
      $pp->tokens, [qw|paragraph_break list_item text line_break|]
    );
  };
}