package PML;

our $VERSION = '0.1';

use strict;
use warnings;
use boolean;

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

	my $tokenizer = PML::Tokenizer->new( pml => $pml );

	my @stack = ();

	while(my $token = $tokenizer->get_next_token) {

		my $type = $token->type;

		if ($type eq 'CHAR') {
			$html .= $token->content;
		}
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
