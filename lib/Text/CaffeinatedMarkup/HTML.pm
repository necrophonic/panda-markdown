package Text::CaffeinatedMarkup::HTML;

use strict;
use v5.10;
use Moo;
extends 'Text::CaffeinatedMarkup::PullParser';

use Log::Declare;
use boolean;

has html => ( is => 'rwp', default => sub {''} );

has in_paragraph   => ( is => 'rw' );
has in_strong      => ( is => 'rw' );
has in_emphasis    => ( is => 'rw' );

use Readonly;
Readonly my $PARAGRAPH_START => '<p>';
Readonly my $PARAGRAPH_END   => '</p>';


# ------------------------------------------------------------------------------

sub do {
	my ($self,$cml) = @_;

	# init
	$self->_set_html('');
	$self->in_paragraph(false);
	$self->in_strong(false);
	$self->in_emphasis(false);

	info "Starting with HTML [%s]", $self->html;

	$self->tokenize( $cml );

	return $self->html;
}

# ------------------------------------------------------------------------------

sub handle_text {
	my ($self) = @_;
	my $content = $self->token->content;

	unless ($self->in_paragraph) {
		$content = $PARAGRAPH_START . $content;
		$self->in_paragraph( true );
	}

	$self->_append_html( $content );
}

# ------------------------------------------------------------------------------

sub handle_emphasis {
	my ($self) = @_;	
	
	my $tag;
	$_=$self->token->type;
	my $access = 'in_'.$_;	
	/strong/    && do { $tag = 'strong' };
	/emphasis/  && do { $tag = 'em' };
	/underline/ && do { $tag = 'u' };
	/delete/    && do { $tag = 'del' };
	/insert/    && do { $tag = 'ins' };

	$self->_parse_error('bad emphasis tag map in html') unless $tag;
	$self->_append_html( $self->$access ? "</$tag>" : "<$tag>" );
	$self->$access( !$self->$access );
}

# ------------------------------------------------------------------------------

sub handle_link {
	my ($self) = @_;	

	my $href = $self->token->href;
	my $text = $self->token->text || $href;

	$self->_append_html( qq|<a href="$href">$text</a>| );
}

# ------------------------------------------------------------------------------

sub handle_image {
	my ($self) = @_;

	my $src    = $self->token->src;
	my $width  = $self->token->width  ? ' width="'.$self->token->width.'"' : '';
	my $height = $self->token->height ? ' height="'.$self->token->height.'"' : '';	

	my $class  = '';
	if ($_ = $self->token->align) {
		/^left$/    && do { $class=' class="pull-left"' };
		/^right$/   && do { $class=' class="pull-right"' };
		/^stretch$/ && do { $class=' class="stretch"' };
		/^center$/  && do { $class=' class="center"' };
	}

	$self->_append_html(qq|<img src="$src"$width$height$class>|);
}

# ------------------------------------------------------------------------------

sub handle_divider {
	my ($self) = @_;
	$self->_append_html('<hr>');
}

# ------------------------------------------------------------------------------

sub handle_header {
	my ($self) = @_;
	my $level   = $self->token->level;
	my $content = $self->token->content;
	$self->_append_html(qq|<h$level>$content</h$level>|);
}

# ------------------------------------------------------------------------------

sub parse_end {
	my ($self) = @_;
	if ($self->in_paragraph) {
		# Still in a paragraph, so finalise it
		$self->_append_html( $PARAGRAPH_END );
	}
}

# ------------------------------------------------------------------------------

sub _append_html {
	my ($self, $append) = @_;
	$self->_set_html( $self->html . $append );
}

# ------------------------------------------------------------------------------

1;
