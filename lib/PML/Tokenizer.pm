package PML::Tokenizer;

use v5.10;

use strict;
use warnings;
use boolean;

use Moo;
use PML::Tokenizer::Token;

use PML::LinkToken;
use PML::ImageToken;

my $debug = false;

has 'pml'	 	 => ( is => 'rw', required => true, trigger => \&_tokenize ); # Raw PML input
has 'tokens' 	 => ( is => 'rw' ); # Array
has 'chars'		 => ( is => 'rw' ); # Array

# Parsing
has 'state'		 => ( is => 'rw' );
has 'content'	 => ( is => 'rw' );
has 'head_level' => ( is => 'rw' );

has 'link_data'	 		  => ( is => 'rw' );
has 'image_data' 		  => ( is => 'rw' );
has 'row_block_modifiers' => ( is => 'rw' );

# Matching contexts
has 'matching_context' => ( is => 'rw' );

has 'data_context' => ( is => 'rw' ); # "data" or "row_data"



use Readonly;
Readonly my $MAX_HEAD_LEVEL => 6;

# Control chars
Readonly my $C_EM			   => '/';
Readonly my $C_STRONG		   => '*';
Readonly my $C_ROW_BLOCK	   => '@';
Readonly my $C_QUOTE 		   => '"';
Readonly my $C_UNDER		   => '_';
Readonly my $C_PARA			   => "\n";
Readonly my $C_S_LINK 		   => '[';
Readonly my $C_E_LINK 		   => ']';
Readonly my $C_S_IMAGE		   => '{';
Readonly my $C_E_IMAGE		   => '}';
Readonly my $C_HEADER		   => '#';
Readonly my $C_S_ROW_MODIFIERS => '[';
Readonly my $C_E_ROW_MODIFIERS => ']';
Readonly my $C_COLUMN		   => '|';

# -----------------------------------------------------------------------------

sub _data_state {
	my ($self, $c) = @_;

	if ($c eq $C_HEADER) {
		# Possible header
		$self->_move_to_state('p_heading');
		$self->head_level(0); # Reset header level counter
	}
	elsif ($c eq $C_EM) 		{ $self->_move_to_state('p_emphasis')  	}
	elsif ($c eq $C_STRONG) 	{ $self->_move_to_state('p_strong')  	}
	elsif ($c eq $C_UNDER)		{ $self->_move_to_state('p_underline') 	}
	elsif ($c eq $C_QUOTE) 		{ $self->_move_to_state('p_quote') 	 	}
	elsif ($c eq $C_PARA)		{ $self->_move_to_state('p_newpara')	}
	elsif ($c eq $C_S_LINK)		{ $self->_move_to_state('p_s_link')    	}	
	elsif ($c eq $C_S_IMAGE)	{ $self->_move_to_state('p_s_image')	}			
	elsif ($c eq $C_ROW_BLOCK)	{ $self->_move_to_state('p_row_block')	}
	elsif ($c eq ' ') {
		# If we're in a block, output it, otherwise skip it
		if ($self->_is_block_open || $self->_is_head_block_open) {
			$self->_new_char_token(' ');
		}
	}
	elsif ($c eq $C_PARA) {
		$self->_requeue_char(' ');				
	}
	else {								 				
		if (!$self->_is_block_open && !$self->_is_head_block_open) {
			$self->_new_token('S_BLOCK','[[S_BLOCK]]');
		}
		$self->_new_char_token( $c );
	}
	return;
}


# -----------------------------------------------------------------------------

sub _tokenize {
	my ($self) = @_;

	# Initial state is 'data'
	$self->state('data');

	$self->matching_context({});
	$self->data_context('data');

	# Tokens initially empty
	$self->tokens([]);

	my @chars = split //, $self->pml;
	$self->chars(\@chars);
	
	# Parse until we run out of data
	while (@chars) {
		my $c = shift @chars;

		D("Read [$c] - Current state [",$self->state,"]");
		
		my $state = $self->state;

		if ($state eq 'data') {
			$self->_data_state( $c );
		}
		elsif ($state eq 'row_data') {
			if ($c eq $C_HEADER) {
				# Possible header
				$self->_move_to_state('p_heading');
				$self->head_level(0); # Reset header level counter
			}
			elsif ($c eq $C_EM) 		{ $self->_move_to_state('p_emphasis')  	}
			elsif ($c eq $C_STRONG) 	{ $self->_move_to_state('p_strong')  	}
			elsif ($c eq $C_UNDER)		{ $self->_move_to_state('p_underline') 	}
			elsif ($c eq $C_QUOTE) 		{ $self->_move_to_state('p_quote') 	 	}
			elsif ($c eq $C_PARA)		{ $self->_move_to_state('p_newpara')	}
			elsif ($c eq $C_S_LINK)		{ $self->_move_to_state('p_s_link')    	}	
			elsif ($c eq $C_S_IMAGE)	{ $self->_move_to_state('p_s_image')	}	
			elsif ($c eq $C_ROW_BLOCK)	{ $self->_move_to_state('p_row_block')	}		
			elsif ($c eq ' ') {
				# If we're in a block, output it, otherwise skip it
				if ($self->_is_block_open || $self->_is_head_block_open) {
					$self->_new_char_token(' ');
				}
			}
			elsif ($c eq $C_PARA) {
				$self->_requeue_char(' ');				
			}
			elsif ($c eq $C_COLUMN) {				
				$self->_move_to_state('p_column');		
				next;
			}
			else {								 				
				if (!$self->_is_block_open && !$self->_is_head_block_open) {
					$self->_new_token('S_BLOCK','[[S_BLOCK]]');
				}
				$self->_new_char_token( $c );
			}

			
		}
		elsif ($state eq 'p_column') {

			if ($c eq $C_COLUMN) {
				if ($self->_is_open('COLUMN')) {
					# Already open, so this is a closing tag.
					$self->_close_block_if_open;
					$self->_new_token('E_COLUMN');
				}
				else {
					$self->_new_token('S_COLUMN');
				}				
			}
			else {
				$self->_output_char_and_requeue_next( $C_COLUMN, $c );
			}
			$self->_move_back_to_context_data_state;
			next;
			
		}
		elsif ($state eq 'p_strong'	  ) { $self->_emit_control_token( $c, 'STRONG',    '[[STRONG]]', $C_STRONG ) }
		elsif ($state eq 'p_underline') { $self->_emit_control_token( $c, 'UNDERLINE', '[[UNDER]]',  $C_UNDER  ) }	
		elsif ($state eq 'p_emphasis' ) { $self->_emit_control_token( $c, 'EMPHASIS',  '[[EMPH]]',   $C_EM    	) }
		elsif ($state eq 'p_quote'	  ) { $self->_emit_control_token( $c, 'QUOTE', 	   '[[QUOTE]]',  $C_QUOTE 	) }		
		elsif ($state eq 'p_row_block') {

			if ($c eq $C_ROW_BLOCK) {
				# ROW_BLOCK start/end tag
				if ($self->_is_open('ROW_BLOCK')) {
					# Already open, so this must be a closing tag.
					# Finalise the row and move back to normal data state.					
					$self->_close_block_if_open;
					$self->_new_token('E_ROW_BLOCK');
					$self->data_context('data');
					$self->_move_to_state('data');
					next;				
				}				
				# Looks like we have a real starting ROW_BLOCK. We need
				# to check whether there are any modifiers.
				$self->_move_to_state('p_row_block_modifiers');				
			}
			else {
				# Not a real control, output plain char and
				# push current back to queue.
				$self->_output_char_and_requeue_next( $C_ROW_BLOCK, $c );				
			}
			next;

		}
		elsif ($state eq 'p_row_block_modifiers') {

			if ($c eq $C_S_ROW_MODIFIERS) {
				$self->row_block_modifiers('');
				$self->_move_to_state('row_block_modifiers');
				next;
			}
			# No modifiers, so output row token and move back to data state.
			$self->_new_token( 'S_ROW_BLOCK' );
			$self->_move_back_to_context_data_state;			
			$self->_requeue_char( $c );

		}
		elsif ($state eq 'row_block_modifiers') {

			if ($c eq $C_E_ROW_MODIFIERS) {
				# Finish modifiers so output modifier data along with a
				# new S_ROW_BLOCK token and move to data state.
				$self->_new_token( 'S_ROW_BLOCK', $self->row_block_modifiers );
				$self->data_context('row_data');
				$self->_move_to_state('row_data');				
			}
			else {
				$self->row_block_modifiers( $self->row_block_modifiers.$c );
			}
			next;

		}
		elsif ($state eq 'p_s_image')	{

			if ($c eq $C_S_IMAGE) {
				$self->_move_to_state('image_data');
				$self->image_data('');				
			}
			else { $self->_output_char_and_requeue_next( $C_S_IMAGE, $c ) }			

		}
		elsif ($state eq 'image_data') {

			if ($c eq $C_E_IMAGE) {
				# Definitely starting an image now, so if there's an open block, close it.
				$self->_close_block_if_open;
				$self->_move_to_state( 'p_e_image' );
				next;
			}			
			$self->image_data( $self->image_data.$c );			

		}
		elsif ($state eq 'p_e_image') {

			if ($c eq $C_E_IMAGE) {
				# Finish the image token
				D(" -> Write image token [",$self->image_data,"]");
				#$self->_new_token( 'IMAGE', $self->image_data);

				my ($src,$options) = split /\|/, $self->image_data;

				my $image_token = PML::ImageToken->new( src => $src );

				if ($options) {
					my @options = split /,/, $options;
					foreach my $option (@options) {

						if 	  ($option eq '&gt;&gt;') { $image_token->align('>>'); }
						elsif ($option eq '&lt;&lt;') { $image_token->align('<<'); }
						elsif ($option =~ /H(\d+)/)	  { $image_token->height($1);  }
						elsif ($option =~ /W(\d+)/)	  { $image_token->width($1);   }
					}
				}
				
				push @{$self->tokens}, $image_token;
				$self->_move_back_to_context_data_state;					
			}
			else {
				# Otherwise still in the image data so add
				# the char to the current image data and move
				# to consume the next char.
				$self->image_data( $self->image_data.$c );
				$self->_requeue_char( $c );
			}
			next;
		}
		elsif ($state eq 'p_s_link') {

			if ($c eq $C_S_LINK) {
				$self->_move_to_state('link_data');
				$self->link_data('');
			}
			else { $self->_output_char_and_requeue_next( $C_S_LINK, $c ) }
			
		}		
		elsif ($state eq 'link_data') {

			if ( $c eq $C_E_LINK ) {
				$self->_move_to_state( 'p_e_link' );
				next;
			}
			else {
				# Whilst in 'link_data' state, treat anything other than
				# link closing tags as char data into the temporary link data.				
				$self->link_data( $self->link_data.$c );
				next;
			}

		}
		elsif ($state eq 'p_e_link') {

			if ($c eq $C_E_LINK) {
				# Finish the link token
				D(" -> Write link token [",$self->link_data,"]");

				my ($href,$text) = split /\|/, $self->link_data;				

				D(" -> Write link token");
				my $link_token = PML::LinkToken->new( url => $href );
				$link_token->text( $text );

				push @{$self->tokens}, $link_token;				
				$self->_move_back_to_context_data_state;
			}
			else {
				# Otherwise still in the link data so add
				# the char to the current link data and move
				# to consume the next char.
				$self->link_data( $self->link_data.$c );
				$self->_requeue_char( $c );				
			}
			
		}
		elsif ($state eq 'p_newpara') {

			if ($c eq $C_PARA) {
				$self->_close_block_if_open;				
			}
			else {
				# If there was just a single one then output a break token
				# and push the next char back to the queue.					
				$self->_new_token( 'BREAK', '' );
				$self->_requeue_char( $c );				
			}
			$self->_move_back_to_context_data_state;			

		}
		elsif ($state eq 'p_heading') {

			if ($c eq $C_HEADER) {
				# Started a header already, so increment the
				# level that we've reached
				$self->head_level($self->head_level+1);

				# If we've reached the max level then error
				if ($self->head_level>$MAX_HEAD_LEVEL) {
					die "Bad HEADER sequence - too long";
				}
			}			
			else {
				# If we've at least reached header level 1 then we output a header token.
				# Otherwise assume it's just a hash character so output that and what we
				# just read as character tokens.
				$self->_finalise_heading;				
				$self->_requeue_char( $c );
				$self->_move_back_to_context_data_state;
			}

		}
		next; # Not needed, just makes flow more explicit :p
	}

	# Fix heading at end of input.
	# Reached end of input so deal with any open header tokens.
	if ($self->state eq 'p_heading') {
		$self->_finalise_heading;
	}

	# Make sure that BLOCKs are closed, so if the last token wasn't a block,
	# let's emit one.
	if ($self->_is_block_open) {
		$self->_new_token( 'E_BLOCK', '' );
	}

	return;
}

# -----------------------------------------------------------------------------

sub _move_back_to_context_data_state {
	my ($self) = @_;
	$self->_move_to_state( $self->data_context );
	return;
}

# -----------------------------------------------------------------------------

sub _output_char_and_requeue_next {
	my ($self, $char_to_output, $char_to_requeue) = @_;
	$self->_new_char_token( $char_to_output  );
	$self->_requeue_char  ( $char_to_requeue );
	return;
}

# -----------------------------------------------------------------------------

sub _requeue_char {
	my ($self, $char_to_requeue) = @_;
	unshift @{$self->chars}, $char_to_requeue;
	return;
}

# -----------------------------------------------------------------------------

sub _emit_control_token {
	my ($self, $char, $type, $content, $plain) = @_;

	if ($char eq $plain) {
		# If there isn't a block open, then we need to open on		
		$self->_new_token( 'S_BLOCK', '[[S_BLOCK]]') unless $self->_is_block_open;		

		# If the token isn't already listed as Start or End then
		# determine which we need.
		if ($type =~ /^(E|S)_/) {
			$self->_new_token( $type, $content );
		}
		else {
			$self->_new_token( ($self->_is_open($type) ?'E':'S')."_$type", $content );		
		}
	}
	else {
		# If not a match then output the potential
		# that we had as a plain char token.
		$self->_output_char_and_requeue_next( $plain, $char );		
	}	
	$self->_move_back_to_context_data_state;
}

# -----------------------------------------------------------------------------

sub _close_block_if_open {	 
	$_[0]->_new_token( 'E_BLOCK', '[[E_BLOCK]]' ) if $_[0]->_is_block_open;	
	return;
}

# -----------------------------------------------------------------------------

sub _is_open {
	my ($self, $type) = @_;
	return ($_[0]->matching_context->{$type}||0)%2;
}

# -----------------------------------------------------------------------------

sub _is_block_open {	
	return ($_[0]->matching_context->{BLOCK}||0)%2		
}

# -----------------------------------------------------------------------------

sub _is_head_block_open {	
	return ($_[0]->matching_context->{HEAD1}||0)%2
		|| ($_[0]->matching_context->{HEAD2}||0)%2
		|| ($_[0]->matching_context->{HEAD3}||0)%2
		|| ($_[0]->matching_context->{HEAD4}||0)%2
		|| ($_[0]->matching_context->{HEAD5}||0)%2
		|| ($_[0]->matching_context->{HEAD6}||0)%2;
}

# -----------------------------------------------------------------------------

sub _finalise_heading {
	my ($self) = @_;
	if ((my $level = $self->head_level) > 0) {
		
		my $open_or_close = $self->_is_open("HEAD$level") ?'E':'S';
		
		# If we've currently got a block open, then we need to close it.
		if ($self->_is_block_open && $open_or_close eq 'S') {
			$self->_new_token( 'E_BLOCK', '[[E_BLOCK]]');			
		}

		# Output the appropriate level header token
		$self->_new_token( $open_or_close."_HEAD$level", "[[H$level]]" );		
	}
	else {
		# Treat as plain # and whatever we just read
		$self->_new_token( 'S_BLOCK','[[S_BLOCK]]') unless ($self->_is_block_open);
		$self->_new_token( 'CHAR', '#' );
	}
	return;
}

# -----------------------------------------------------------------------------

sub _new_char_token {
	my ($self, $content) = @_;
	$self->_new_token('CHAR',$content);
	return;
}

# -----------------------------------------------------------------------------

sub _new_token {
	my ($self, $type, $content) = @_;
	
	$content ||= '';

	D(" -> Emit [$type] token [$content]");
	
	# Need to update the matching counts so for that we need the specific
	# type (without any leading S_ or E_)
	(my $specific_type = $type) =~ s/^(S|E)_//;	
	if ($specific_type ne 'CHAR') {
		$self->matching_context->{$specific_type}++;
		D(" -> Update matching for '$specific_type'");
	}


	push @{$self->tokens},
		 PML::Tokenizer::Token->new( type => $type, content => $content );
	return;
}

# -----------------------------------------------------------------------------

sub _move_to_state {
	my ($self, $state) = @_;
	D(" -> Move to state [$state]");
	$self->state($state);
	return;
}

# -----------------------------------------------------------------------------

sub get_next_token {
	my ($self) = @_;

	if ( @{$self->tokens}>0 ) {
		return shift @{$self->tokens};
	}
	else {
		return 0;
	}
}

# -----------------------------------------------------------------------------

sub D {warn @_ if $debug}

1;

=pod

=head1 TITLE

PML::Tokenizer

=head1 SYNOPSIS

  use PML::Tokenizer;

  my $tokenizer = PML::Tokenizer->new( pml => $pml_string );

  while( my $token = $tokenizer->get_next_token ) {
	
	# Do something with the token

  }


=head1 DESCRIPTION

Simple tokenizer for PML tokens.

=head1 METHODS

=head2 get_next_token

Return the next token or C<0> if there are no more tokens read.

=cut

