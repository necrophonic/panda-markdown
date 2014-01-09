#!/usr/bin/env perl

use strict;

use Test::More;
use Test::Exception;

use Readonly;
Readonly my $CLASS => 'Text::CaffeinatedMarkup::PullParser';

use_ok $CLASS;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($OFF);

my $parser = undef;
my @tokens = ();

# ------------------------------------------------------------------------------

sub get_tokens_string {	join ',', map { $_->{type} } @{$_[0]}; }

# ------------------------------------------------------------------------------

subtest "Simple section break" => sub {
	$parser = $CLASS->new(pml => '~~');
	my @tokens = $parser->get_all_tokens;
	is(get_tokens_string(\@tokens),'SECTIONBREAK','Section break');	
};

# ------------------------------------------------------------------------------

done_testing();
