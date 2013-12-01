#!/usr/bin/env perl

use strict;

use Test::More;
use Test::Exception;

use Readonly;
Readonly my $CLASS => 'PML::PullParser';

use_ok $CLASS;

my $parser;

subtest "Simple parse" => sub {
	$parser = $CLASS->new(pml => 'Simple **PML** to parse');

	my @tokens = ();

	lives_ok {@tokens = $parser->get_all_tokens()}, 'Parse without error';

};

done_testing();
