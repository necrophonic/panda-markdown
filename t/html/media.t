#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;
use Test::More;
use Text::CaffeinatedMarkup::HTML;

plan tests => 1;

	my $parser = Text::CaffeinatedMarkup::HTML->new;

	test_basic_image_media();

done_testing();

# ------------------------------------------------------------------------------

sub test_basic_image_media {
	subtest 'Basic Images' => sub {
		plan tests => 3;
		is $parser->do( '{{image.jpg|<<,W50,H60}}' ),
		   '<img class="cml-img cml-pulled-left" src="image.jpg" width="50" height="60">',
		   'simple image';

		is $parser->do( '{{image.jpg}}' ),
		   '<img class="cml-img" src="image.jpg">',
		   'simple image with no options';

		is $parser->do( 'See this {{image.jpg}}' ),
		   '<p>See this <img class="cml-img" src="image.jpg"></p>',
		   'simple image with no options in paragraph';
	};
}

# ------------------------------------------------------------------------------