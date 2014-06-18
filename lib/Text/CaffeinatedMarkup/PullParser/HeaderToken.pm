package Text::CaffeinatedMarkup::PullParser::HeaderToken;

use strict;
use v5.10;
use Moo;
extends 'Text::CaffeinatedMarkup::PullParser::BaseToken';

use Log::Declare;

has level   => ( is => 'rw' );
has content => ( is => 'rwp', default => sub {''} );

sub append_content {
	my ($self, $char) = @_;
	debug "Append char [%s] to header token", $char [HEADER_TOKEN];
	$self->_set_content( $self->content . $char );
	return;
}

1;