#!/usr/bin/env perl

use strict;

use Test::More;
use Test::Exception;

use Readonly;
Readonly my $CLASS => 'Text::CaffeinatedMarkup::PullParser';

use_ok $CLASS;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($OFF);

my $parser;
my @tokens = ();
	

# ------------------------------------------------------------------------------

sub get_tokens_string {	join ',', map { $_->{type} } @{$_[0]}; }

# ------------------------------------------------------------------------------

subtest "Simple parse" => sub {
	$parser = $CLASS->new(pml => 'Simple **PML** to parse');
	lives_ok {@tokens = $parser->get_all_tokens()}, 'Parse without error';	
};

# ------------------------------------------------------------------------------

done_testing();
