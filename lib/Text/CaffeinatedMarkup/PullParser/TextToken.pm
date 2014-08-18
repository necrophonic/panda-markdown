package Text::CaffeinatedMarkup::PullParser::TextToken;

use strict;
use v5.10;
use Moo;
extends 'Text::CaffeinatedMarkup::PullParser::BaseToken';

use Log::Declare;

has content => ( is => 'rwp', default => sub {''} );

sub append_content {
	my ($self, $char) = @_;
	debug "Append char [%s] to text token", $char [TEXT_TOKEN];
	$self->_set_content( $self->content . $char );
	return;
}

1;