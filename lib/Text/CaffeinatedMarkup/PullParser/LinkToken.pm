package Text::CaffeinatedMarkup::PullParser::LinkToken;

use strict;
use v5.10;
use Moo;
extends 'Text::CaffeinatedMarkup::PullParser::BaseToken';

use Log::Declare;

has href => ( is => 'rwp', default => sub {''} );
has text => ( is => 'rwp', default => sub {''} );

# ------------------------------------------------------------------------------

sub append_href {
	my ($self, $char) = @_;
	debug "Append char [%s] to link token href", $char [LINK_TOKEN HREF];
	$self->_set_href( $self->href . $char );
	return;
}

# ------------------------------------------------------------------------------

sub append_text {
	my ($self, $char) = @_;
	debug "Append char [%s] to link token text", $char [LINK_TOKEN TEXT];
	$self->_set_text( $self->text . $char );
	return;
}

# ------------------------------------------------------------------------------

1;