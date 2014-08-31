#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;

use Test::More;
use lib 't/lib';
use Helpers;

plan tests => 3;

	use_ok 'Text::CaffeinatedMarkup::HTML';
	new_ok 'Text::CaffeinatedMarkup::HTML';

	local $/=undef;	
	test_html_data_document(Text::CaffeinatedMarkup::HTML->new,<DATA>);

done_testing();


__DATA__
This is a simple doc.

There isn't much in it,
but it's perfectly formed.

  - item 1
  - item 2
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
<p>This is a simple doc.</p><p>There isn't much in it,<br>but it's perfectly formed.</p><ul><li class="cml-list-item"><p>item 1</p></li><li class="cml-list-item"><p>item 2</p></li></ul>
