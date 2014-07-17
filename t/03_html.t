#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;

use Test::More;

plan tests => 9;

	use_ok 'Text::CaffeinatedMarkup::HTML';
	new_ok 'Text::CaffeinatedMarkup::HTML';

	my $parser = Text::CaffeinatedMarkup::HTML->new;

	test_basic_text();
	test_basic_text_with_emphasis();
	test_basic_link();
	test_divider();
	test_headers();
	test_basic_image_media();
    test_basic_row();

done_testing();

# ------------------------------------------------------------------------------

sub test_basic_text {
	subtest 'Basic text' => sub {
		plan tests => 1;				
		my $html   = $parser->do( 'The quick brown foo' );
		is $html, '<p>The quick brown foo</p>', 'plain text';
	};
}

# ------------------------------------------------------------------------------

sub test_basic_text_with_emphasis {
	subtest 'Basic text with emphasis' => sub {
		plan tests => 2;
		
		is $parser->do( 'The **quick** brown //foo//' ),
		   '<p>The <strong>quick</strong> brown <em>foo</em></p>',
		   'plain text with emphasis';		

		is $parser->do( 'The **quick //brown// foo**' ),
		   '<p>The <strong>quick <em>brown</em> foo</strong></p>',
		   'plain text with emphasis';		
	};
}

# ------------------------------------------------------------------------------

sub test_basic_link {
	subtest 'Basic link' => sub {
		plan tests => 3;

		is $parser->do( '[[http://example.com|my site]]' ),
		   '<a href="http://example.com">my site</a>',
		   'basic link';

		is $parser->do( '[[http://example.com]]' ),
		   '<a href="http://example.com">http://example.com</a>',
		   'basic link (no text)';

		is $parser->do( 'Go here [[http://example.com|a]] its great!' ),
		   '<p>Go here <a href="http://example.com">a</a> its great!</p>',
		   'basic link in text';
	};
}

# ------------------------------------------------------------------------------

sub test_divider {
	subtest 'Divider' => sub {
		plan tests => 1;
		is $parser->do( '~~' ),
		   '<hr>',
		   'basic divider';
	};
}

# ------------------------------------------------------------------------------

sub test_headers {
	subtest 'Headers' => sub {
		plan tests => 2;
		is $parser->do( '# My Header' ),
		   '<h1>My Header</h1>',
		   'level one header';

		is $parser->do( '#### My Header' ),
		   '<h4>My Header</h4>',
		   'level four header';
	};
}

# ------------------------------------------------------------------------------

sub test_basic_image_media {
	subtest 'Basic Images' => sub {
		plan tests => 3;
		is $parser->do( '{{image.jpg|<<,W50,H60}}' ),
		   '<img src="image.jpg" width="50" height="60" class="pull-left">',
		   'simple image';

		is $parser->do( '{{image.jpg}}' ),
		   '<img src="image.jpg">',
		   'simple image with no options';

		is $parser->do( 'See this {{image.jpg}}' ),
		   '<p>See this <img src="image.jpg"></p>',
		   'simple image with no options in paragraph';
	};
}

# ------------------------------------------------------------------------------

sub test_basic_row {
    subtest 'Basic row' => sub {
        plan tests => 3;
        is $parser->do(qq|==\nFirst\n--\nSecond\n==|),
           q|<div class="row-2"><span class="column"><p>First</p></span><span class="column"><p>Second</p></span></div>|,
           'two column row';

        is $parser->do(qq|==\nFirst\n--\n**Second**\n==|),
           q|<div class="row-2"><span class="column"><p>First</p></span><span class="column"><p><strong>Second</strong></p></span></div>|,
           'two column row with emphasis';

        is $parser->do(qq|==\nFirst\n--\n{{image.jpg}}\n==|),
           q|<div class="row-2"><span class="column"><p>First</p></span><span class="column"><img src="image.jpg"></span></div>|,
           'two column row with image';
    };
}

# ------------------------------------------------------------------------------
