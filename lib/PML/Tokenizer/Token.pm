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
		TEXT	1
		S_BOLD	1	E_BOLD	1
		S_EMPH	1	E_EMPH	1
		S_UNDR	1	E_UNDR	1
	);

	die "Token type '$val' not valid" unless exists $types{$val};
}

"budweiser";

