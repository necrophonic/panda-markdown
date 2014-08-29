#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;
use Test::More;
use Text::CaffeinatedMarkup::HTML;

plan tests => 1;

	my $parser = Text::CaffeinatedMarkup::HTML->new;

	test_lists();

done_testing();


# ------------------------------------------------------------------------------

sub test_lists {
	subtest 'Lists' => sub {
		plan tests => 7;

		is $parser->do(qq|  - Item 1\n  - Item 2|),
		   q|<ul><li><p>Item 1</p></li><li><p>Item 2</p></li></ul>|,
		   'simple unordered list';

		is $parser->do(qq|\n\n  - Item 1\n  - Item 2|),
		   q|<ul><li><p>Item 1</p></li><li><p>Item 2</p></li></ul>|,
		   'prefixed by breaks';

		is $parser->do(qq|  - Item 1\n  - **Item** 2|),
		   q|<ul><li><p>Item 1</p></li><li><p><strong>Item</strong> 2</p></li></ul>|,
		   'simple unordered list with some emphasis';

		is $parser->do(qq|  - Item 1.1\n    - Item 2.1\n  - Item 1.2|),
		   q|<ul><li><p>Item 1.1</p></li><ul><li><p>Item 2.1</p></li></ul><li><p>Item 1.2</p></li></ul>|,
		   'simple unordered list with some emphasis';

		is $parser->do(<<EOT
  - Item 1.1
    1 Item 2.1
  - Item 1.2
    12 Item 3.1
EOT
),
		   q|<ul><li><p>Item 1.1</p></li><ol><li><p>Item 2.1</p></li></ol><li><p>Item 1.2</p></li><ol><li><p>Item 3.1<br></p></li></ol></ul>|,
		   'simple ordered and unordered';

		is $parser->do(<<EOT
  - {{cat.jpg}}
  - {{dog.jpg}}
EOT
),
		   q|<ul><li><img src="cat.jpg"></li><li><img src="dog.jpg"></li></ul>|,
		   'list of images';

		is $parser->do(<<EOT
  - [[http://example.com]]
EOT
),
		   q|<ul><li><p><a href="http://example.com">http://example.com</a></p></li></ul>|,
		   'list of images';
	};
}


# ------------------------------------------------------------------------------