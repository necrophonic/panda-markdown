package PML::Tokenizer;

use v5.10;

use strict;
use warnings;
use boolean;

use Moo;
use PML::Tokenizer::Token;

my $debug = false;

has 'pml'	 	 => ( is => 'rw', required => true, trigger => \&_tokenize ); # Raw PML input
has 'tokens' 	 => ( is => 'rw' ); # Array

# Parsing
has 'state'		 => ( is => 'rw' );
has 'content'	 => ( is => 'rw' );
has 'head_level' => ( is => 'rw' );

# Matching contexts
has 'matching_context' => ( is => 'rw' );

# has 'open_HEAD1' 	 => ( is => 'rw', default => sub{0} );
# has 'open_HEAD2' 	 => ( is => 'rw', default => sub{0} );
# has 'open_HEAD3' 	 => ( is => 'rw', default => sub{0} );
# has 'open_HEAD4' 	 => ( is => 'rw', default => sub{0} );
# has 'open_HEAD5' 	 => ( is => 'rw', default => sub{0} );
# has 'open_HEAD6' 	 => ( is => 'rw', default => sub{0} );
# has 'open_UNDERLINE' => ( is => 'rw', default => sub{0} );
# has 'open_STRONG' 	 => ( is => 'rw', default => sub{0} );
# has 'open_EMPHASIS'  => ( is => 'rw', default => sub{0} );
# has 'open_BLOCK' 	 => ( is => 'rw', default => sub{0} );

use Readonly;
Readonly my $MAX_HEAD_LEVEL => 6;

# -----------------------------------------------------------------------------

sub _tokenize {
	my ($self) = @_;

	# Initial state is 'data'
	$self->state('data');

	$self->matching_context({});

	# Tokens initially empty
	$self->tokens([]);

	my @chars = split //, $self->pml;

	# Start with a BLOCK token
	$self->_new_token( 'S_BLOCK', '' );
	
	# Parse until we run out of data
	while (@chars) {
		my $c = shift @chars;

		D("Read [$c] - Current state [",$self->state,"]");
		
		if ($self->state eq 'data') {

			if 	  ($c =~ /\*/) { $self->_move_to_state('p_strong') 	  }
			elsif ($c =~ /_/ ) { $self->_move_to_state('p_underline') }
			elsif ($c =~ /\//) { $self->_move_to_state('p_emphasis')  }
			elsif ($c =~ /\#/) { $self->_move_to_state('p_heading'); $self->head_level(0) }
			elsif ($c =~ /\n/) {
				#$self->_move_to_state('space_after_nl');
				$self->_new_token( 'CHAR', ' ');
				$self->_move_to_state('data');
			}			
			else { $self->_new_token( 'CHAR', $c ) }

		}		
		elsif ($self->state eq 'p_heading') {

			if ($c =~ /\#/) {
				# Started a header already, so increment the
				# level that we've reached
				$self->head_level($self->head_level+1);

				# If we've reached the max level then error
				if ($self->head_level>$MAX_HEAD_LEVEL) {
					die "Bad HEADER sequence - too long";
				}
			}
			else {
				# If we've at least reached header level 1 then we
				# output a header token. Otherwise assume it's just
				# a hash so output that and what we just read.		
				$self->_finalise_heading;				
				unshift @chars, $c;
				$self->_move_to_state('data');
			}

		}
		elsif ($self->state eq 'p_strong') {
			$self->_emit_control_token( $c, 'STRONG', '[[STRONG]]', '*', \@chars );
		}
		elsif ($self->state eq 'p_underline') {
			$self->_emit_control_token( $c, 'UNDERLINE', '[[UNDER]]', '_', \@chars );
		}
		elsif ($self->state eq 'p_emphasis') {			
			$self->_emit_control_token( $c, 'EMPHASIS', '[[EMPH]]', '/', \@chars );			
		}
		else {
			$self->_move_to_state('data');
		}
		next;
	}

	# Fix heading at end of input.
	# Reached end of input so deal with any open header tokens.
	if ($self->state eq 'p_heading') {
		$self->_finalise_heading;
	}

	# Make sure that BLOCKs are closed, so if the last token wasn't a block,
	# let's emit one.
	if ($self->tokens->[ $#{$self->tokens} ]->type ne 'E_BLOCK' ) {
		$self->_new_token( 'E_BLOCK', '' );
	}

	return;
}

# -----------------------------------------------------------------------------

sub _emit_control_token {
	my ($self, $char, $type, $content, $plain, $chars_ar) = @_;

	if ($char eq $plain) {
		$self->_new_token( ($self->matching_context->{$type}++ %2?'E':'S')."_$type", $content );
	}
	else {
		$self->_new_token( 'CHAR', $plain );
		unshift @$chars_ar, $char;				
	}
	$self->_move_to_state('data');
}

# -----------------------------------------------------------------------------

sub _finalise_heading {
	my ($self) = @_;
	if ((my $level = $self->head_level) > 0) {
		$self->_new_token( ($self->matching_context->{"HEAD$level"}++ %2?'E':'S')."_HEAD$level", "[[H$level]]" );
		#self->_new_token( "HEAD$level", "[[H$level]]" );
	}
	else {
		# Treat as plain # and whatever we just read
		$self->_new_token( 'CHAR', '#' );
	}
	return;
}

# -----------------------------------------------------------------------------

sub _new_token {
	my ($self, $type, $content) = @_;
	if ($type eq 'CHAR') {
		D(" -> Emit [$type] token [$content]");
	}
	else {
		D(" -> Emit [$type] token");
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

sub D {say @_ if $debug}

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

