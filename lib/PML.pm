package PML;

our $VERSION = '0.1';

use strict;
use warnings;
use boolean;

use HTML::Escape;
use PML::Tokenizer;

# ------------------------------------------------------------------------------

sub _type_to_tag {
	return {
		HEAD1		=> 'h1',
		HEAD2		=> 'h2',
		HEAD3		=> 'h3',
		HEAD4		=> 'h4',
		HEAD5		=> 'h5',
		HEAD6		=> 'h6',
		STRONG		=> 'strong',
		EMPHASIS	=> 'em',
		UNDERLINE	=> 'u'
	};
}

# ------------------------------------------------------------------------------

sub markdown {
	my ($pml) = @_;
	my $html = '';

	# Clean the PML before we start as we don't allow 
	# interpretable HTML.
	$pml = HTML::Escape::escape_html($pml);

	my $tokenizer = PML::Tokenizer->new( pml => $pml );

	# Initialise stack for nested tag matching	
	# Stack is upside down so we know the "head" is always
	# at position zero.
	my @stack = ();

	while(my $token = $tokenizer->get_next_token) {

		my $type = $token->type;

		if ($type eq 'CHAR') { $html .= $token->content }
		else {			
			# If the new token is the same as the top of
			# the stack then we pop that off and output a
			# closing version. Otherwise we output an
			# opening version and push onto the stack.
			if (@stack && $stack[0] eq $type) {
				$html .= _end_type($type);
				shift @stack;
			}
			else {
				$html .= _start_type($type);
				unshift @stack, $type;
			}
		}
	}

	$html =~ s/ +/ /g; # Multiple spaces
	$html =~ s/^ *//g; # Leading spaces
	$html =~ s/ *$//g; # Trailing spaces

	return "$html\n";
}

# ------------------------------------------------------------------------------

sub _start_type { return '<' ._type_to_tag->{$_[0]}.'>' }
sub _end_type   { return '</'._type_to_tag->{$_[0]}.'>' }

# ------------------------------------------------------------------------------

1;

=pod

=head1 TITLE

PML - Panda Markdown Language to HTML converter

=head1 SYNOPSIS

  use PML;

  my $pml = 'The //quick// brown __fox__ jumped over the lazy **dog**';

  my $html = PML::markdown( $pml );

=head1 DESCRIPTION

Convert text written in PML into HTML.

=cut
