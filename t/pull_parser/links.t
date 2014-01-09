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

subtest "Simple link" => sub {
	$parser = $CLASS->new(pml => "Go here [[http://www.google.com]] it's cool");
	@tokens = $parser->get_all_tokens;
	is(get_tokens_string(\@tokens),'STRING,LINK,STRING','Link with just href');
	is($tokens[1]->{href}, 'http://www.google.com', 'Href set ok');
	is($tokens[1]->{text}, '', 'Text is null');
};

# ------------------------------------------------------------------------------

subtest "Simple link with text" => sub {
	$parser = $CLASS->new(pml => "Go here [[http://www.google.com|Google]] it's cool");
	@tokens = $parser->get_all_tokens;
	is(get_tokens_string(\@tokens),'STRING,LINK,STRING','Link with text');
	is($tokens[1]->{href}, 'http://www.google.com', 'Href set ok');
	is($tokens[1]->{text}, 'Google', 'Text set ok');
};

# ------------------------------------------------------------------------------

done_testing();
