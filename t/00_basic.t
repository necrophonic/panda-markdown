#!/usr/bin/env perl
use strict;

use Test::More;
use Test::Exception;

plan tests => 4;

	use_ok 'Text::CaffeinatedMarkup';
	can_ok 'Text::CaffeinatedMarkup', qw|markup|;
	my $cm = new_ok 'Text::CaffeinatedMarkup';
	
	dies_ok {$cm->markup( 'fake', 'pdf' )} 'dies with unsupported handler';
	


done_testing;

