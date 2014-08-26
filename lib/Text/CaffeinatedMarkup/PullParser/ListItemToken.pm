package Text::CaffeinatedMarkup::PullParser::ListItemToken;

use strict;
use v5.10;
use Moo;
extends 'Text::CaffeinatedMarkup::PullParser::BaseToken';

use Log::Declare;

has type  => ( is => 'rw' );
has level => ( is => 'rw' );

sub BUILDARGS {
	my ($class, @args) = @_;
	return { type => $args[0], level => $args[1] };
}

1;