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

subtest "Simple image" => sub {
	$parser = $CLASS->new(pml => "Look at this {{cat.jpg}} Nice huh?");
	@tokens = $parser->get_all_tokens;
	is(get_tokens_string(\@tokens),'STRING,IMAGE,STRING','Image with just src');
	is($tokens[1]->{src}, 'cat.jpg', 'Src set ok');
	is($tokens[1]->{options}, '', 'Options is null');
};

# ------------------------------------------------------------------------------

subtest "Simple image with options" => sub {
	$parser = $CLASS->new(pml => "Look at this {{cat.jpg|>>,W29}} Nice huh?");
	@tokens = $parser->get_all_tokens;
	is(get_tokens_string(\@tokens),'STRING,IMAGE,STRING','Image with just src');
	is($tokens[1]->{src}, 'cat.jpg', 'Src set ok');
	is($tokens[1]->{options}, '>>,W29', 'Options set ok');
};

# ------------------------------------------------------------------------------

done_testing();
