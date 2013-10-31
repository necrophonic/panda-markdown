package PML::Tokenizer;

use strict;
use warnings;
use boolean;

use Moo;
use PML::Tokenizer::Token;

has 'pml'	 => ( is => 'rw', required => true ); # Raw PML input
has 'tokens' => ( is => 'rw' ); # Array


sub get_next_token {
	my ($self) = @_;

	if ( @{$self->tokens}>0 ) {
		return shift @{$self->tokens};
	}
	else {
		return 0;
	}
}



"budweiser";

=pod

=head1 TITLE

PML::Tokenizer

=head1 SYNOPSIS

  use PML::Tokenizer;

  my $tokenizer = PML::Tokenizer->new();


=head1 DESCRIPTION

Simple tokenizer for PML tokens.

=head1 METHODS

=head2 get_next_token

Return the next token of C<0> if there are no more tokens read.

=cut

