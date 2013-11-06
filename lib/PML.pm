package PML;

use v5.10;

our $VERSION = '0.3';

use strict;
use warnings;
use boolean;

use HTML::Escape;
use PML::Tokenizer;

# ------------------------------------------------------------------------------

sub _type_to_tag {
	my ($type) = @_;	
	$type ||= '';
	my $map = {
		HEAD1		=> 'h1',
		HEAD2		=> 'h2',
		HEAD3		=> 'h3',
		HEAD4		=> 'h4',
		HEAD5		=> 'h5',
		HEAD6		=> 'h6',
		STRONG		=> 'strong',
		EMPHASIS	=> 'em',
		UNDERLINE	=> 'u',
		BLOCK		=> 'p',
		QUOTE		=> 'blockquote',
		LINK		=> 'a',
	};
	if (exists $map->{$type}) { return $map->{$type}}
	die "No mapping for type '$type'";
}

# ------------------------------------------------------------------------------

sub markdown {
	my ($pml) = @_;
	my $html = '';

	# Clean the PML before we start as we don't allow 
	# interpretable HTML.
	$pml = HTML::Escape::escape_html($pml);	

	# Fix "quot"s
	$pml =~ s/\&quot;/\"/g;

	
	$pml =~ s/^ *//g; # Leading spaces
	$pml =~ s/ *$//g; # Trailing spaces

	my $tokenizer = PML::Tokenizer->new( pml => $pml );

	# Initialise stack for nested tag completion
	# Stack is upside down so we know the "head" is always
	# at position zero.
	my @stack = ();

	while(my $token = $tokenizer->get_next_token) {

		my $type = $token->type;		

		if 	  ($type eq 'CHAR') { $html .= $token->content }
		elsif ($type eq 'LINK') {

			# Parse the content data to get the text alternative (if defined)
			my ($href,$text) = split /\|/, $token->content;
			$text ||= $href;

			$html .= qq|<a href="$href">$text</a>|;

		}
		else {			

			my ($start_end, $item) = $type =~ /^(S|E)_(.+)$/;

			if ($start_end eq 'S') {
				$html .= _start_type($item);
				unshift @stack, $item
			}
			else {				
				if ($stack[0] ne $item) {
					die "Unbalanced tags!"
				}
				else {
					$html .= _end_type($item);
					shift @stack; # If ok then pull off the head
				}
			}
		}
	}

	$html =~ s/ +/ /g; # Multiple spaces

	return "$html\n";
}

# ------------------------------------------------------------------------------

sub _start_type { return '<' ._type_to_tag($_[0]).'>' }
sub _end_type   { return '</'._type_to_tag($_[0]).'>' }

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
