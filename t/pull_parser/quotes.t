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

subtest "Simple quotes" => sub {
	subtest "Simple quote - no cite" => sub {
		$parser = $CLASS->new(pml => '""A wise man once said""');
		@tokens = $parser->get_all_tokens;
		is get_tokens_string(\@tokens), 'QUOTE', 'got quote token';
		is $tokens[0]->{body}, 'A wise man once said', 'body ok';
		is $tokens[0]->{cite}, '', 'no cite as expected';
	};

	subtest "Simple quote - with cite" => sub {
		$parser = $CLASS->new(pml => '""A wise man once said|Some guy""');
		@tokens = $parser->get_all_tokens;
		is get_tokens_string(\@tokens), 'QUOTE', 'got quote token';
		is $tokens[0]->{body}, 'A wise man once said', 'body ok';
		is $tokens[0]->{cite}, 'Some guy', 'cite as expected';
	};

};

# ------------------------------------------------------------------------------

subtest "Quotes nested in other blocks" => sub {
	subtest "Root level" => sub {
		$parser = $CLASS->new(pml => 'This is true: ""A wise man once said"" Is it not?');
		@tokens = $parser->get_all_tokens;
		is get_tokens_string(\@tokens), 'STRING,QUOTE,STRING', 'got quote token with strings';
		is $tokens[1]->{body}, 'A wise man once said', 'body ok';
		is $tokens[1]->{cite}, '', 'no cite as expected';
	};

	subtest "In a column" => sub {
		$parser = $CLASS->new(pml => qq!==\n||""A wise man once said""\n==!);
		@tokens = $parser->get_all_tokens;
		is get_tokens_string(\@tokens), 'ROW,COLUMN,QUOTE,ROW', 'got quote token with strings';
		is $tokens[2]->{body}, 'A wise man once said', 'body ok';
		is $tokens[2]->{cite}, '', 'no cite as expected';
	};
};

# ------------------------------------------------------------------------------

done_testing();
