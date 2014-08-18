package Text::CaffeinatedMarkup::PushParser;

use strict;

use Moo;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(markup);

has 'chars'     => ( is => 'rwp' );
has 'output'    => ( is => 'rwp' );
has 'pointer'   => ( is => 'rwp' );
has 'state'     => ( is => 'rwp' );

sub do {
	my ($self, $cml) = @_;
}

# ------------------------------------------------------------------------------

# Clean up internals
sub _init {
	my ($self) = @_;
	$self->_set_output('');
	$self->_set_pointer(-1);
	$self->_set_state('newline');
	return;
}

# ------------------------------------------------------------------------------

sub _do {
	my ($self) = @_;

	while($self->pointer < $#{$self->chars}) {

		$self->_inc_pointer;

		my $char  = $self->chars->[$self->pointer];
		my $state = $self->state;

		
		unless (defined $state) {
			# Will be at start of the parsing and nothing's happened yet....

			# Just text
			$self->_set_state('text');
			$self->event_start_text;
			$self->_append_to_output($char);
			next;
		}

		if ($state eq 'text') {


			# Still just text
			$self->_append_to_output($char);
			next;
		}


		
	}

	return $self->output;
}

# ------------------------------------------------------------------------------

sub _inc_pointer {$_[0]->{pointer}++}
sub _dec_pointer {$_[0]->{pointer}--}

# ------------------------------------------------------------------------------

sub _peek {
	my ($self) = @_;
	if ($self->pointer < $#[$self->chars]) {
		return $self->chars->[$self->pointer + 1];
	}
	return undef;
}

# ------------------------------------------------------------------------------

sub _append_to_output {
	my ($self, $to_append) = @_;
	$self->_set_output( $self->output . $to_append );
	return;
}


sub event_start_text {}

1;
