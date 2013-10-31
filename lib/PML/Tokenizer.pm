package PML::Tokenizer;

use v5.16;

use strict;
use warnings;
use boolean;

use Moo;
use PML::Tokenizer::Token;

my $debug = true;

has 'pml'	 	 => ( is => 'rw', required => true, trigger => \&_tokenize ); # Raw PML input
has 'tokens' 	 => ( is => 'rw' ); # Array

# Parsing
has 'state'		 => ( is => 'rw' );
has 'content'	 => ( is => 'rw' );
has 'head_level' => ( is => 'rw' );

use Readonly;
Readonly my $MAX_HEAD_LEVEL => 6;

# -----------------------------------------------------------------------------

sub _tokenize {
	my ($self) = @_;

	# Initial state is 'data'
	$self->state('data');

	# Tokens initially empty
	$self->tokens([]);

	my @chars = split //, $self->pml;
	
	# Parse until we run out of data
	while (@chars) {
		my $c = shift @chars;

		D("Read [$c] - Current state [",$self->state,"]");
		
		if ($self->state eq 'data') {

			if 	  ($c =~ /\*/) { $self->_move_to_state('p_strong') 	  }
			elsif ($c =~ /_/ ) { $self->_move_to_state('p_underline') }
			elsif ($c =~ /\//) { $self->_move_to_state('p_emphasis')  }
			elsif ($c =~ /\#/) { $self->_move_to_state('p_heading'); $self->head_level(0) }
			else           	   { $self->_new_token( 'CHAR', $c )   	  }

		}
		elsif ($self->state eq 'p_heading') {

			if ($c =~ /\#/) {
				# Started a header already, so increment the
				# level that we've reached
				$self->head_level($self->head_level+1);
			}
			else {
				# If we've at least reached header level 1 then we
				# output a header token. Otherwise assume it's just
				# a hash so output that and what we just read.
				if ($self->head_level>0) {
					$self->_new_token( 'HEAD'.$self->head_level, '[[H'.$self->head_level.']]' );
				}
				else {
					# Treat as plain # and whatever we just read
					$self->_new_token( 'CHAR', '#' );
					$self->_new_token( 'CHAR', $c  );
				}
				$self->_move_to_state('data');
			}

		}
		elsif ($self->state eq 'p_strong') {

			if ($c =~ /\*/) { $self->_new_token( 'STRONG', '[[STRONG]]' ); }
			else {
				$self->_new_token( 'CHAR', '*' );
				$self->_new_token( 'CHAR', $c  );
			}
			$self->_move_to_state('data');

		}
		elsif ($self->state eq 'p_underline') {

			if ($c =~ /_/) { $self->_new_token( 'UNDERLINE', '[[UNDER]]' ); }
			else {
				$self->_new_token( 'CHAR', '_' );
				$self->_new_token( 'CHAR', $c  );
			}
			$self->_move_to_state('data');

		}
		elsif ($self->state eq 'p_emphasis') {

			if ($c =~ /\//) { $self->_new_token( 'EMPHASIS', '[[EMPH]]' ); }
			else {
				$self->_new_token( 'CHAR', '/' );
				$self->_new_token( 'CHAR', $c  );
			}
			$self->_move_to_state('data');

		}
		next;
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

sub D {
	say @_ if $debug;
}

1;

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

