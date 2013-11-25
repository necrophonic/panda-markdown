package PML::HTMLFormatter;

use v5.10;

use strict;
use warnings;
use boolean;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($ERROR);

use Moo;
use PML::Tokenizer;

has 'tokenizer' => ( is => 'lazy' );

has 'is_paragraph_open' => ( is => 'rwp' );
has 'is_column_open'    => ( is => 'rwp' );
has 'is_row_open' 	    => ( is => 'rwp' );
has 'stack'			    => ( is => 'rwp' );

has 'html_chunks'	     => ( is => 'rwp' );
has 'html_chunk_pointer' => ( is => 'rwp' );

my $END = 1;

# ------------------------------------------------------------------------------

sub format {
	my ($self, $pml) = @_;
	
	$pml || $self->fatal("Must supply 'pml' to HTMLFormatter");

	my @tokens 	  = @{$self->tokenizer->tokenize( $pml )->tokens};	

	$self->_set_stack([]);
	$self->_set_is_paragraph_open(false);
	$self->_set_is_column_open(false);
	$self->_set_is_row_open(false);


	$self->_set_html_chunks([]);
	$self->_set_html_chunk_pointer(0);

	my $tmp_column_count = 0;

	TRACE "-----------------------------------------";
	TRACE "BEGIN HTML FORMAT";
	
	my $tmp_row_html = '';
	my %tmp_row_data = ();

	for my $token (@tokens) {
		
		my $type = $token->{type};

		TRACE "[Type: $type]";

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
				$self->_append_to_html( $self->_html_for_paragraph($END) );
				$self->_set_is_paragraph_open(false);
			}
			else {
				$self->_append_to_html( $self->_html_for_paragraph );
				$self->_set_is_paragraph_open(true);
			}
		}

		elsif ($type eq 'LINE_BREAK') {
			$self->_open_paragraph_if_not_open;			
			$self->_append_to_html( $self->_html_for_line_break );
		}

		# HEADER
		elsif ($type eq 'HEADER') {			
			my $level = $token->{level};
			my $text  = $token->{text};			
			$self->_append_to_html( $self->_html_for_header( $level, $text ));
		}

		# ROW
		elsif ($type eq 'ROW') {			

			if ($self->is_row_open) {
				# If a column is still open, then close it
				if ($self->is_column_open) {					
					$self->_close_paragraph_if_open;
					$self->_append_to_html( $self->_html_for_close_row );
					$self->_set_is_column_open(false);	
				}

				# If there's already a row open, then this must close it.
				$self->_set_is_row_open(false);
				$self->_close_paragraph_if_open;

				$self->html_chunks->[ $self->html_chunk_pointer ]
							= $self->_html_for_open_row(
										$tmp_column_count,
										$self->html_chunks->[ $self->html_chunk_pointer ]
							);

				$tmp_column_count = 0; # Reset count
			}
			else {
				# Not already a row open, so open one
				%tmp_row_data = (rows=>[]);
				$self->_set_is_row_open(true);			
			}
			
			# Start or move to a new html chunk
			$self->_inc_chunk_pointer;
		}

		# COLUMN
		elsif ($type eq 'COLUMN') {			

			$self->fatal("Column outside of row") unless $self->is_row_open;
			
			if ($self->is_column_open) {
				TRACE "Column is open - closing";
				$self->_close_paragraph_if_open;
				$self->_append_to_html( $self->_html_for_close_column );				
			}
			
			# If a previous paragraph was open, then we want to
			# close it before we start a new column.
			$tmp_column_count++;			
			$self->_append_to_html( $self->_html_for_open_column );
			$self->_set_is_column_open(true);
		}

		# IMAGE
		elsif ($type eq 'IMAGE') {
			# If the image is inline (no specified alignment) then
			# open a paragraph if one isn't open.			
			$self->_open_paragraph_if_not_open unless $token->{align};
			$self->_append_to_html( $self->_html_for_image(
										$token->{src},
										{
											align  => $token->{align},
											width  => $token->{width},
											height => $token->{height},
											align  => $token->{align},
										}  
			 						));
		}

		# LINK
		elsif ($type eq 'LINK') {
			$self->_open_paragraph_if_not_open;
			$self->_append_to_html( $self->_html_for_link( $token->{href}, $token->{text}) );
		}
	}

	# Clean up
	# Clear down stack
	for my $tag (@{$self->stack}) {
		if ($tag eq 'PARA') { $self->_append_to_html( $self->_html_for_paragraph($END)) }
	}

	return join '', @{$self->html_chunks};
}

# ------------------------------------------------------------------------------

sub _append_to_html {
	my ($self, $text_to_append) = @_;	
	TRACE "Append '$text_to_append' to html chunk '".$self->html_chunk_pointer."'";
	$self->html_chunks->[$self->html_chunk_pointer] .= $text_to_append;	
}

# ------------------------------------------------------------------------------

sub _inc_chunk_pointer {
	my ($self) = @_;

	# Increment if there's content in the current chunk, otherwise carry on using it
	if ($self->html_chunks->[$self->html_chunk_pointer]) {
		$self->_set_html_chunk_pointer( $self->html_chunk_pointer + 1 );
	}
	return;
}

# ------------------------------------------------------------------------------

sub _open_paragraph_if_not_open {
	my ($self) = @_;
	unless ($self->is_paragraph_open) {		
		$self->_append_to_html( $self->_html_for_paragraph );
		$self->_set_is_paragraph_open(true);
		$self->_add_to_stack('PARA');
		TRACE "Close paragaph";
	}
}

# ------------------------------------------------------------------------------

sub _close_paragraph_if_open {
	my ($self) = @_;
	if ($self->is_paragraph_open) {
		$self->_append_to_html( $self->_html_for_paragraph($END));
		$self->_set_is_paragraph_open(false);
		my $tag = $self->_pop_from_stack;
		if ($tag ne 'PARA') {
			$self->fatal("_close_paragraph_if_open expected PARA at end of stack");
		}
	}
}

# ------------------------------------------------------------------------------

sub _output_simple {
	my ($self, $tag) = @_;
	my $match = $self->_is_tag_matched($tag);
	if ($match) {
		shift @{$self->stack}; # Pull match off stack
		$self->_append_to_html( $self->_html_for_strong($END) ) 	if $tag eq 'STRONG';
		$self->_append_to_html( $self->_html_for_underline($END) ) 	if $tag eq 'UNDERLINE';
		$self->_append_to_html( $self->_html_for_emphasis($END) ) 	if $tag eq 'EMPHASIS';
		$self->_append_to_html( $self->_html_for_quote($END) ) 		if $tag eq 'QUOTE';
	}
	else {
		# Check whether paragaph is open and open if not.
		unless ($self->is_paragraph_open) {
			$self->_append_to_html( $self->_html_for_paragraph );
			unshift @{$self->stack}, 'PARA';
			$self->_set_is_paragraph_open(true);
		}		
		$self->_append_to_html( $self->_html_for_strong ) 	 if $tag eq 'STRONG';
		$self->_append_to_html( $self->_html_for_underline ) if $tag eq 'UNDERLINE';
		$self->_append_to_html( $self->_html_for_emphasis )  if $tag eq 'EMPHASIS';
		$self->_append_to_html( $self->_html_for_quote )     if $tag eq 'QUOTE';
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
	ERROR "!!HTMLFormatter Error: $msg!!";
	die "$msg\n\n";
}

# --------------------------------------------------------------[ BUILDERS ]----

sub _build_tokenizer {
	my ($self) = @_;
	return PML::Tokenizer->new;
}

# --------------------------------------------------------[ HTML OUTPUTERS ]----

# <sub>(self, is_end)

sub _html_for_strong 	{ $_[1] ? '</strong>' 	  : '<strong>'		}
sub _html_for_underline { $_[1] ? '</u>' 	  	  : '<u>' 			}
sub _html_for_emphasis 	{ $_[1] ? '</em>' 	  	  : '<em>'  		}
sub _html_for_quote		{ $_[1] ? '</blockquote>' : '<blockquote>' 	}
sub _html_for_paragraph { $_[1] ? '</p>' 		  : '<p>'		 	}

# ------------------------------------------------------------------------------

sub _html_for_line_break   { '<br>'   }

# ------------------------------------------------------------------------------

sub _html_for_open_column  { '<div class="column">' };
sub _html_for_close_column { '</div>' }

# ------------------------------------------------------------------------------

sub _html_for_open_row {
	my ($self, $columns, $html_chunk ) = @_;
	return qq|<div class="clearfix col-$columns">$html_chunk</div>|;	
}
sub _html_for_close_row { '</div>' }

# ------------------------------------------------------------------------------

sub _html_for_header {
	my ($self,$level,$text) = @_;
	return "<h$level>$text</h$level>";
}

# ------------------------------------------------------------------------------

sub _html_for_link {
	my ($self, $href, $text) = @_;	
	return qq|<a href="$href"|
			.($href=~/^http/?' target="_new"':'')  # External links
			.'>'
			.($text?$text:$href)
			.'</a>';
}

# ------------------------------------------------------------------------------

sub _html_for_image {
	my ($self, $src, $options) = @_;

	my $width  = ($options->{width}  ? ' width="'  .$options->{width}  .'px"' : '');
	my $height = ($options->{height} ? ' height="' .$options->{height} .'px"' : '');

	my $align = '';
	if ($options->{align}) {
		if ($options->{align} eq 'left')  {$align = ' class="pulled-left"'   }
		if ($options->{align} eq 'right') {$align = ' class="pulled-right"'  }
		if ($options->{align} eq 'center'){$align = ' class="centered"' 	 }
		if ($options->{align} eq 'span')  {$align = ' class="stretch-horiz"' }
	}
	return  qq|<img src="$src"$align$width$height>|;
}

# ------------------------------------------------------------------------------



1;

__END__

=head1 TITLE

PML::HTMLFormatter - simple formatter for tokenized PML

=head1 SYNOPSIS

	use PML::HTMLFormatter;
	
	my $formatter = PML::HTMLFormatter->new;

	my $html = $formatter->format($pml);

=head1 DESCRIPTION

Default HTML formatter for PML.

=head1 OVERRIDABLE FORMATTER METHODS

These methods should each return a chunk of html in a string.

  $self->_html_for_strong( <IS_END_TAG> )
  $self->_html_for_emphasis( <IS_END_TAG> )
  $self->_html_for_underline( <IS_END_TAG> )
  $self->_html_for_quote( <IS_END_TAG> )
  $self->_html_for_header( <LEVEL>, <TEXT> )
  $self->_html_for_link( <HREF>, <TEXT> )
  $self->_html_for_image( <SRC>, <OPTIONS [align,width,height]> )


=head2 _html_for_strong

Return html for STRONG tags. Start and end.

  @param		is_end	1=output end tag, 0=output start tag
  @returns 	html string

Examples

  my $html = $self->_html_for_strong;    # '<strong>'
  my $html = $self->_html_for_strong(1); # '</strong>'

=end

