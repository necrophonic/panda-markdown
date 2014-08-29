package Text::CaffeinatedMarkup::Text;

use strict;
use v5.10;
use Moo;
extends 'Text::CaffeinatedMarkup::PullParser';

use Log::Declare;
use boolean;

has text => ( is => 'rwp', default => sub {''} );

has in_paragraph => ( is => 'rw' );

sub do {
	my ($self,$cml) = @_;

	info "Starting with CML [%s]", $cml [FORMAT_TEXT];

	$self->_set_text('');
	$self->in_paragraph(false);
	
	$self->tokenize($cml);

	return $self->text;
}

# ------------------------------------------------------------------------------

sub handle_text {
	my ($self) = @_;	
	$self->in_paragraph(true) unless $self->in_paragraph;
	$self->_append_text( $self->token->content );	
}

# ------------------------------------------------------------------------------

sub handle_emphasis {
	my ($self) = @_;

	$self->_open_paragraph_if_not;

	$_=$self->token->type;
	/strong/    && do { $self->_append_text('**') };
	/emphasis/  && do { $self->_append_text('*') };
	/underline/ && do { $self->_append_text('_') };
	/delete/    && do { $self->_append_text('-') };
	/insert/    && do { $self->_append_text('+') };
	return;
}

# ------------------------------------------------------------------------------

sub handle_linebreak {
	my ($self) = @_;	
	return unless $self->in_paragraph;
	$self->_append_text("\n");
}

# ------------------------------------------------------------------------------

sub handle_paragraphbreak {
	my ($self) = @_;
	return unless $self->in_paragraph;
	$self->in_paragraph(false);
	$self->_append_text("\n\n");
}

# ------------------------------------------------------------------------------

sub _open_paragraph_if_not {
    my ($self) = @_;    
    $self->in_paragraph(true) unless $self->in_paragraph;
}

# ------------------------------------------------------------------------------

sub _append_text {
	my ($self,$append) = @_;
	$self->_set_text( $self->text . $append );
}

1;
