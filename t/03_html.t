#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;

use Test::More;

plan tests => 3;

	use_ok 'Text::CaffeinatedMarkup::HTML';
	new_ok 'Text::CaffeinatedMarkup::HTML';

	my $parser = Text::CaffeinatedMarkup::HTML->new;

	can_ok 'Text::CaffeinatedMarkup::HTML',
	       qw|
	       		handle_listitem handle_blockquote handle_text handle_emphasis
	       		handle_link handle_media handle_header handle_row
	       		handle_columndivider handle_linebreak handle_paragraphbreak	       		
	       |;
	
done_testing();

# ------------------------------------------------------------------------------
