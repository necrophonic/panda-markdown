package Text::CaffeinatedMarkup::PullParser::MediaToken;

use strict;
use v5.10;
use Moo;
extends 'Text::CaffeinatedMarkup::PullParser::BaseToken';

use Log::Declare;

has src 	=> ( is => 'rwp', default => sub {''} );
has options => ( is => 'rwp', default => sub {''} );

has align	=> ( is => 'rw' );
has width	=> ( is => 'rw' );
has height	=> ( is => 'rw' );
has caption => ( is => 'rw' );

# ------------------------------------------------------------------------------

sub append_src {
	my ($self, $char) = @_;
	debug "Append char [%s] to media  token src", $char [IMAGE_TOKEN SRC];
	$self->_set_src( $self->src . $char );
	return;
}

# ------------------------------------------------------------------------------

sub append_options {
	my ($self, $char) = @_;
	debug "Append char [%s] to media token raw options", $char [IMAGE_TOKEN OPTIONS];
	$self->_set_options( $self->options . $char );
	return;
}

# ------------------------------------------------------------------------------

sub finalise {
	my ($self) = @_;

	foreach ( split/,/,$self->options ) {
		/<</        && do { $self->align('left') 	};
		/>>/        && do { $self->align('right') 	};
		/<>/        && do { $self->align('stretch')	};
		/></        && do { $self->align('center') 	};
		/W(\d+)/    && do { $self->width($1)	    };
		/H(\d+)/    && do { $self->height($1)	    };
		/^"(.+)"$/  && do { $self->caption($1)      };
	}
	return;
}

1;
