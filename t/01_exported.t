#!/usr/bin/env perl
use strict;

use Test::More;


plan tests => 1;

	use Text::CaffeinatedMarkup qw|markup|;
	can_ok 'main', qw|markup|;

	print markup('abc');
	

done_testing;

