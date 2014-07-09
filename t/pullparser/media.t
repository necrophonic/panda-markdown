#!/usr/bin/perl
use strict;

use Test::More;

use lib 't/lib';
use Helpers;

use Text::CaffeinatedMarkup::PullParser;

plan tests => 2;

    can_ok 'Text::CaffeinatedMarkup::PullParser', qw|handle_media|;

    my $pp = Text::CaffeinatedMarkup::PullParser->new;

    test_simple_image_media();

done_testing();

# ------------------------------------------------------------------------------

sub test_simple_image_media {
    subtest 'test simple image media' => sub {
        plan tests => 1;
        $pp->tokenize('{{image.jpg}}');
        test_expected_tokens_list( $pp->tokens, [qw|media|] );
    };
}

# ------------------------------------------------------------------------------

