#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;

use Test::More;
use lib 't/lib';
use Helpers;

plan tests => 3;

	use_ok 'Text::CaffeinatedMarkup::Text';
	new_ok 'Text::CaffeinatedMarkup::Text';

	local $/=undef;	
	test_html_data_document(Text::CaffeinatedMarkup::Text->new,<DATA>);

done_testing();


__DATA__
This is a simple doc.

There isn't much in it,
but it's perfectly formed.

  - item 1
  - item 2
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
This is a simple doc.

There isn't much in it,
but it's perfectly formed.

  - item 1
  - item 2
