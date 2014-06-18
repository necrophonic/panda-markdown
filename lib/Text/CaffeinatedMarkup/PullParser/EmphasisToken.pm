package Text::CaffeinatedMarkup::PullParser::EmphasisToken;

use strict;
use v5.10;
use Moo;
extends 'Text::CaffeinatedMarkup::PullParser::BaseToken';

has type => ( is => 'rwp', required => 1 );

sub BUILDARGS {
	my ($class, @args) = @_;

	return { type => $args[0] };
}

1;