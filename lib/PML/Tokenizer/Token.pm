package PML::Tokenizer::Token;

use strict;
use warnings;
use boolean;

use Moo;

has 'type' 	  => ( is => 'rw', isa => \&validate_type, required => true );
has 'content' => ( is => 'rw' );

sub validate_type {
	my ($val) = @_;

	my %types = qw(
		CHAR		1
		STRONG		1
		EMPHASIS	1
		UNDERLINE	1
		HEAD1 1 HEAD2 1 HEAD3 1 HEAD4 1 HEAD5 1 HEAD6 1
	);

	die "Token type '$val' not valid" unless exists $types{$val};
}

"budweiser";

