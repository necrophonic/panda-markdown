#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;

use Test::More;

plan tests => 12;

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
    test_line_breaks();
    test_paragraph_breaks();
    test_escaping();

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
		plan tests => 3;
		is $parser->do( '# My Header' ),
		   '<h1>My Header</h1>',
		   'level one header';

		is $parser->do( '#### My Header' ),
		   '<h4>My Header</h4>',
		   'level four header';

		is $parser->do( qq|Text\n\n## My Header| ),
		   '<p>Text</p><h2>My Header</h2>',
		   'header after break';
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
        plan tests => 4;
        is $parser->do(qq|==\nFirst\n--\nSecond\n==|),
           q|<div class="row-2"><span class="column"><p>First</p></span><span class="column"><p>Second</p></span></div>|,
           'two column row';

        is $parser->do(qq|==\nFirst\n--\n**Second**\n==|),
           q|<div class="row-2"><span class="column"><p>First</p></span><span class="column"><p><strong>Second</strong></p></span></div>|,
           'two column row with emphasis';

        is $parser->do(qq|==\nFirst\n--\n{{image.jpg}}\n==|),
           q|<div class="row-2"><span class="column"><p>First</p></span><span class="column"><img src="image.jpg"></span></div>|,
           'two column row with image';

        is $parser->do(qq|First\n==\nThen a row\n==|),
           q|<p>First</p><div class="row-1"><span class="column"><p>Then a row</p></span></div>|,
           'text before a row';
    };
}

# ------------------------------------------------------------------------------

sub test_line_breaks {
	subtest 'Line Breaks' => sub {
		plan tests => 1;
		is $parser->do(qq|Something\nAfter break|),
		   q|<p>Something<br>After break</p>|,
		   'single break in paragraph';
	};
}

# ------------------------------------------------------------------------------

sub test_paragraph_breaks {
	subtest 'Paragraph Breaks' => sub {
		plan tests => 3;
		is $parser->do(qq|Something\n\nAfter break|),
		   q|<p>Something</p><p>After break</p>|,
		   'single paragraph break';

		is $parser->do(qq|Something\n\n\n\n\nAfter break|),
		   q|<p>Something</p><p>After break</p>|,
		   'elongated paragraph break (multiple collapse to single)';

		is $parser->do(qq|Something\nMore\n\nAfter break|),
		   q|<p>Something<br>More</p><p>After break</p>|,
		   'break and paragraph';
	};
}

# ------------------------------------------------------------------------------

sub test_escaping {
	subtest 'Escaping' => sub {
		plan tests => 2;

		subtest 'Escapes in simple text' => sub {
			is $parser->do(q|Some \**escaped\** %%text [[]]%%|),
			   q|<p>Some **escaped** text [[]]</p>|,
			   'simple single and block escape in text';
		};		

		subtest 'Escapes with newlines' => sub {
			is $parser->do(qq|Some \\**escaped\\**\n\%\%text\n\n[[]]\%\%|),
			   qq|<p>Some **escaped**<br>text\n\n[[]]</p>|,
			   'simple single and block escape in text with newlines';
		};		
	};
}

# ------------------------------------------------------------------------------
