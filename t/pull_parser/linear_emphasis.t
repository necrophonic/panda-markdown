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

sub get_tokens_string {	join ',', map { $_->{type} } @{$_[0]}; }

# ------------------------------------------------------------------------------

subtest "Strong" => sub {
	$parser = $CLASS->new(pml => 'Simple **PML** to parse');
	@tokens = $parser->get_all_tokens;
	is( get_tokens_string(\@tokens), 'STRING,STRONG,STRING,STRONG,STRING', 'Strong in string' );
	is($tokens[0]->{content}, 'Simple ',   'Token #1 correct text'	);
	is($tokens[1]->{type}, 	  'STRONG',    'Token #2 is STRONG'		);
	is($tokens[2]->{content}, 'PML', 	   'Token #3 correct text'	);
	is($tokens[3]->{type}, 	  'STRONG',    'Token #4 is STRONG'		);
	is($tokens[4]->{content}, ' to parse', 'Token #5 correct text'	);

	$parser = $CLASS->new(pml => '**Strong** at start');
	@tokens = $parser->get_all_tokens;
	is( get_tokens_string(\@tokens), 'STRONG,STRING,STRONG,STRING', 'Strong at start' );

	$parser = $CLASS->new(pml => 'At the end is **Strong**');
	@tokens = $parser->get_all_tokens;
	is( get_tokens_string(\@tokens), 'STRING,STRONG,STRING,STRONG', 'Strong at end' );
};

# ------------------------------------------------------------------------------

subtest "Emphasis" => sub {
	$parser = $CLASS->new(pml => 'With //emphasis// in middle');
	@tokens = $parser->get_all_tokens;
	is( get_tokens_string(\@tokens), 'STRING,EMPHASIS,STRING,EMPHASIS,STRING', 'Emphasis in string' );

	$parser = $CLASS->new(pml => '//Emphasis// at start');
	@tokens = $parser->get_all_tokens;
	is( get_tokens_string(\@tokens), 'EMPHASIS,STRING,EMPHASIS,STRING', 'Emphasis at start' );

	$parser = $CLASS->new(pml => 'At the end is //emphasis//');
	@tokens = $parser->get_all_tokens;
	is( get_tokens_string(\@tokens), 'STRING,EMPHASIS,STRING,EMPHASIS', 'Emphasis at end' );
};

# ------------------------------------------------------------------------------

subtest "Underline" => sub {
	$parser = $CLASS->new(pml => 'With __underline__ in middle');
	@tokens = $parser->get_all_tokens;
	is( get_tokens_string(\@tokens), 'STRING,UNDERLINE,STRING,UNDERLINE,STRING', 'Underline in string' );

	$parser = $CLASS->new(pml => '__underline__ at start');
	@tokens = $parser->get_all_tokens;
	is( get_tokens_string(\@tokens), 'UNDERLINE,STRING,UNDERLINE,STRING', 'Underline at start' );

	$parser = $CLASS->new(pml => 'At the end is __underline__');
	@tokens = $parser->get_all_tokens;
	is( get_tokens_string(\@tokens), 'STRING,UNDERLINE,STRING,UNDERLINE', 'Underline at end' );
};

# ------------------------------------------------------------------------------

subtest "Del" => sub {
	$parser = $CLASS->new(pml => 'With --del-- in middle');
	@tokens = $parser->get_all_tokens;
	is( get_tokens_string(\@tokens), 'STRING,DEL,STRING,DEL,STRING', 'Del in string' );

	$parser = $CLASS->new(pml => '--del-- at start');
	@tokens = $parser->get_all_tokens;
	is( get_tokens_string(\@tokens), 'DEL,STRING,DEL,STRING', 'Del at start' );

	$parser = $CLASS->new(pml => 'At the end is --del--');
	@tokens = $parser->get_all_tokens;
	is( get_tokens_string(\@tokens), 'STRING,DEL,STRING,DEL', 'Del at end' );
};

# ------------------------------------------------------------------------------

done_testing();
