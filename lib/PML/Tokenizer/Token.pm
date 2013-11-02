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
		S_STRONG	1	E_STRONG	1
		S_EMPHASIS	1	E_EMPHASIS	1
		S_UNDERLINE	1	E_UNDERLINE	1
		S_HEAD1 1 S_HEAD2 1 S_HEAD3 1 S_HEAD4 1 S_HEAD5 1 S_HEAD6 1
		E_HEAD1 1 E_HEAD2 1 E_HEAD3 1 E_HEAD4 1 E_HEAD5 1 E_HEAD6 1
		S_BLOCK	1 E_BLOCK 1
	);

	die "Token type '$val' not valid" unless exists $types{$val};
}

1;

