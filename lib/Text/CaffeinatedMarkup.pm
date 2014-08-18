package Text::CaffeinatedMarkup;

use strict;
use v5.10;
use Moo;
extends "Exporter";

our $VERSION = 0.13;
our @EXPORT_OK = qw|markup|;

has 'mapping' => (
					is => 'rwp',
					default => sub {{
						html => 'Text::CaffeinatedMarkup::HTML',
						text => 'Text::CaffeinatedMarkup::Text'
					}}
				 );

# ------------------------------------------------------------------------------

sub markup {
	my ($self, $cml, $format) = @_;

	unless (ref $self) {
		# Called as exported function
		my $object = __PACKAGE__->new();
		return $object->markup( $self, $cml ); # self is cml, cml is format
	}

	$format ||= 'html'; # Default if none specified

	die "No handler for '$format'" unless exists $self->mapping->{$format};

	my $parser = $self->mapping->{$format};
	eval "require $parser" ;
	return $parser->new->do( $cml );
}

# ------------------------------------------------------------------------------



1;

=pod

=encoding utf8

=head1 NAME

Text::CaffeinatedMarkup - Implementation of the Caffeinated Markup Lanaguage

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

J Gregory <jgregory@cpan.org>

=cut
