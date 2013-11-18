package PML::HTMLFormatter;

use v5.10;

use strict;
use warnings;
use boolean;

use Log::Log4perl qw(:easy);
#Log::Log4perl->easy_init($TRACE);

use Moo;
use PML::Tokenizer;

has 'tokenizer' => ( is => 'lazy' );

has 'is_paragraph_open' => ( is => 'rwp' );
has 'stack'			    => ( is => 'rwp' );
has 'html'			    => ( is => 'rwp' );

# ------------------------------------------------------------------------------

sub format {
	my ($self, $pml) = @_;
	
	$pml || $self->fatal("Must supply 'pml' to HTMLFormatter");

	my $html 	  = '';
	my @tokens 	  = @{$self->tokenizer->tokenize( $pml )->tokens};	

	$self->_set_stack([]);
	$self->_set_is_paragraph_open(false);
	$self->_set_html( '' );

	TRACE "-----------------------------------------";
	TRACE "BEGIN HTML FORMAT";
	
	my $tmp_row_html = '';

	for my $token (@tokens) {
		
		my $type = $token->{type};

		if ($type eq 'STRING') {
			$self->_open_paragraph_if_not_open;
			$self->_append_to_html($token->{content});
		}

		elsif ($type eq 'STRONG') {
			$self->_output_simple('STRONG','strong');			
		}
		elsif ($type eq 'UNDERLINE') {
			$self->_output_simple('UNDERLINE','u');			
		}
		elsif ($type eq 'EMPHASIS') {
			$self->_output_simple('EMPHASIS','em');			
		}		
		elsif ($type eq 'QUOTE') {
			$self->_output_simple('QUOTE','blockquote');			
		}		

		elsif ($type eq 'PARA') {
			if ($self->is_paragraph_open) {
				unless ($self->_is_tag_matched('PARA')) {
					$self->fatal("Expecting to close paragraph but bad stack head");
				}
				$self->_pop_from_stack;				
				$self->_append_to_html('</p>');
				$self->_set_is_paragraph_open(false);
			}
			else {
				$html .= '<p>';
				$self->_set_is_paragraph_open(true);
			}
		}

		elsif ($type eq 'LINE_BREAK') {
			$self->_open_paragraph_if_not_open;			
			$self->_append_to_html('<br>');
		}

		# HEADER
		elsif ($type eq 'HEADER') {			
			my $level = $token->{level};
			my $text  = $token->{text};
			$self->_append_to_html("<h$level>$text</h$level>");
		}

		# ROW
		# TODO ...

		# COLUMN
		# TODO ...

		# IMAGE
		elsif ($type eq 'IMAGE') {
			# If the image is inline (no specified alignment) then
			# open a paragraph if one isn't open.			
			$self->_open_paragraph_if_not_open unless $token->{align};
			
			my $align = '';
			if ($token->{align}) {
				if ($token->{align} eq 'left')  {$align = ' class="pulled-left"'     }
				if ($token->{align} eq 'right') {$align = ' class="pulled-right"'    }
				if ($token->{align} eq 'center'){$align = ' class="centered"' 	   }
				if ($token->{align} eq 'span')  {$align = ' class="stretch-horiz"' }
			}

			$self->_append_to_html(
					'<img src="'.$token->{src}.'"'
					.$align
					.($token->{width}  ? ' width="' .$token->{width} .'px"' : '')
					.($token->{height} ? ' height="'.$token->{height}.'px"' : '')
					.'>');
		}

		# LINK
		elsif ($type eq 'LINK') {
			$self->_open_paragraph_if_not_open;
			$self->_append_to_html('<a href="'.$token->{href}.'">'
				  .($token->{text}?$token->{text}:$token->{href})
				  .'</a>');
		}


	}

	# Clean up
	# Clear down stack
	for my $tag (@{$self->stack}) {
		if ($tag eq 'PARA') { $self->_append_to_html('</p>') }
	}

	return $self->html;
}

# ------------------------------------------------------------------------------

sub _append_to_html {
	my ($self, $text_to_append) = @_;
	TRACE "Append '$text_to_append' to html";
	$self->_set_html( $self->html . $text_to_append );
}

# ------------------------------------------------------------------------------

sub _open_paragraph_if_not_open {
	my ($self) = @_;
	unless ($self->is_paragraph_open) {		
		$self->_append_to_html('<p>');
		$self->_set_is_paragraph_open(true);
		$self->_add_to_stack('PARA');
	}
}

# ------------------------------------------------------------------------------

sub _output_simple {
	my ($self, $tag, $html_tag) = @_;
	my $match = $self->_is_tag_matched($tag);
	if ($match) {
		shift @{$self->stack}; # Pull match off stack
		$self->_append_to_html('</'.$html_tag.'>');
	}
	else {
		# Check whether paragaph is open and open if not.
		unless ($self->is_paragraph_open) {
			$self->_append_to_html('<p>');
			unshift @{$self->stack}, 'PARA';
			$self->_set_is_paragraph_open(true);
		}
		$self->_append_to_html('<'.$html_tag.'>');
		unshift @{$self->stack}, $tag;
	}
}

# ------------------------------------------------------------------------------

sub _add_to_stack {
	my ($self, $tag) = @_;
	TRACE "Add '$tag' to stack";
	unshift @{$self->stack}, $tag;
}

# ------------------------------------------------------------------------------

sub _pop_from_stack {
	my ($self, $stack_ref) = @_;
	my $tag = shift @{$self->stack};
	TRACE "Pop '$tag' from stack";
	return $tag;
}

# ------------------------------------------------------------------------------

sub _is_tag_matched {
	my ($self, $tag) = @_;
	return @{$self->stack} && $self->stack->[0] eq $tag ? true : false;
}

# ------------------------------------------------------------------------------

sub fatal {
	my ($self, @msg) = @_;
	my $msg = join '',@msg;
	#ERROR "!!Tokenizer Error: $msg!!";
	die "$msg\n\n";
}

# --------------------------------------------------------------[ BUILDERS ]----

sub _build_tokenizer {
	my ($self) = @_;
	return PML::Tokenizer->new;
}

# ------------------------------------------------------------------------------

1;
