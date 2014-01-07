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

subtest "Simple headers 1-6" => sub {
	$parser = $CLASS->new(pml => qq|# Header level 1|);
	@tokens = $parser->get_all_tokens;
	is(get_tokens_string(\@tokens),'HEADER','Header token');
	is($tokens[0]->{level},1,'Header level is 1');
	is($tokens[0]->{text},'Header level 1', 'Header text is correct');
};

# ------------------------------------------------------------------------------

subtest "In line becomes string" => sub {
	$parser = $CLASS->new(pml => qq|String then # Header level 1|);
	@tokens = $parser->get_all_tokens;
	is(get_tokens_string(\@tokens),'STRING','Just a string token');
	is($tokens[0]->{content},'String then # Header level 1', 'Content correct');
};

# ------------------------------------------------------------------------------

done_testing();
