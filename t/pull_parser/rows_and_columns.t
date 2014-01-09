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

subtest "Simple rows" => sub {
	subtest "Single column" => sub {
		$parser = $CLASS->new(pml => "==\n||Column\n==\n");
		my @tokens = $parser->get_all_tokens;
		is(get_tokens_string(\@tokens),
			'ROW,COLUMN,STRING,ROW',
			'Row with single column tokens ok'
		);
	};

	subtest "Two column" => sub {
		$parser = $CLASS->new(pml => "==\n||Column||Column\n==\n");
		my @tokens = $parser->get_all_tokens;
		is(get_tokens_string(\@tokens),
			'ROW,COLUMN,STRING,COLUMN,STRING,ROW',
			'Row with double column tokens ok'
		);
	};
};

# ------------------------------------------------------------------------------

subtest "Row following row" => sub {
	$parser = $CLASS->new(pml => "==\n||Column||Column\n==\n==\n||Column2||Column2\n==\n");
	my @tokens = $parser->get_all_tokens;
	is(get_tokens_string(\@tokens),
		'ROW,COLUMN,STRING,COLUMN,STRING,ROW,ROW,COLUMN,STRING,COLUMN,STRING,ROW',
		'Row with double column tokens ok'
	);
};

# ------------------------------------------------------------------------------

subtest "Columns with markup" => sub {
	my @tokens = ();
	$parser = $CLASS->new(pml => "==\n||There is something **strong** here\n||Blah\n==");
	@tokens = $parser->get_all_tokens;
		is(get_tokens_string(\@tokens),
			'ROW,COLUMN,STRING,STRONG,STRING,STRONG,STRING,COLUMN,STRING,ROW',
			'Column with strong markup'
		);

	$parser = $CLASS->new(pml => "==\n||There is something //emphasised// here\n||Blah\n==");
	@tokens = $parser->get_all_tokens;
		is(get_tokens_string(\@tokens),
			'ROW,COLUMN,STRING,EMPHASIS,STRING,EMPHASIS,STRING,COLUMN,STRING,ROW',
			'Column with emphasis markup'
		);

	$parser = $CLASS->new(pml => "==\n||There is something __underlined__ here\n||Blah\n==");
	@tokens = $parser->get_all_tokens;
		is(get_tokens_string(\@tokens),
			'ROW,COLUMN,STRING,UNDERLINE,STRING,UNDERLINE,STRING,COLUMN,STRING,ROW',
			'Column with Underline markup'
		);

	$parser = $CLASS->new(pml => "==\n||There is something --deleted-- here\n||Blah\n==");
	@tokens = $parser->get_all_tokens;
		is(get_tokens_string(\@tokens),
			'ROW,COLUMN,STRING,DEL,STRING,DEL,STRING,COLUMN,STRING,ROW',
			'Column with delete markup'
		);

	$parser = $CLASS->new(pml => "==\n||[[http://cafpanda.com]]||Blah\n==");
	@tokens = $parser->get_all_tokens;
		is(get_tokens_string(\@tokens),
			'ROW,COLUMN,LINK,COLUMN,STRING,ROW',
			'Column with link markup'
		);

	$parser = $CLASS->new(pml => "==\n||{{panda.png}}||Blah\n==");
	@tokens = $parser->get_all_tokens;
		is(get_tokens_string(\@tokens),
			'ROW,COLUMN,IMAGE,COLUMN,STRING,ROW',
			'Column with image markup'
		);
};

# ------------------------------------------------------------------------------

done_testing();
