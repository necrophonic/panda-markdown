package Text::CaffeinatedMarkup::HTML;

use strict;
use v5.10;
use Moo;
extends 'Text::CaffeinatedMarkup::PullParser';

use Log::Declare;
use boolean;

# To implement
# * spacers
# * list
# * table
# * block code
# * inline code
# * media - other types


has html => ( is => 'rwp', default => sub {''} );

has in_paragraph   => ( is => 'rw' );
has in_strong      => ( is => 'rw' );
has in_emphasis    => ( is => 'rw' );
has in_underline   => ( is => 'rw' );
has in_delete      => ( is => 'rw' );
has in_insert      => ( is => 'rw' );
has in_row         => ( is => 'rw' );
has in_block_quote => ( is => 'rw' );

has current_row    => ( is => 'rw' );

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
	$self->in_underline(false);
	$self->in_delete(false);
	$self->in_insert(false);
    $self->in_row(false);
    $self->in_block_quote(false);

	info "Starting with HTML [%s]", $self->html;

	$self->tokenize( $cml );

	return $self->html;
}

# ------------------------------------------------------------------------------

sub handle_blockquote {
	my ($self) = @_;
	if ($self->in_block_quote) {
		$self->_finalise_paragraph_if_open;
		$self->_append_html('</blockquote>');
		$self->in_block_quote(false);
	}
	else {
		$self->_append_html('<blockquote>');
		$self->in_block_quote(true);
	}
}

# ------------------------------------------------------------------------------

sub handle_text {
	my ($self) = @_;
	my $content = $self->token->content;

    trace "Handle TEXT [%s]", $content [HTML];
    #return unless $content; # Skip empty content

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

    trace "Handle EMPHASIS [%s]",$self->token->type [HTML];

    $self->_open_paragraph_if_not;
	$self->_parse_error('bad emphasis tag map in html') unless $tag;
	$self->_append_html( $self->$access ? "</$tag>" : "<$tag>" );
	$self->$access( !$self->$access );
}

# ------------------------------------------------------------------------------

sub handle_link {
	my ($self) = @_;	

	my $href = $self->token->href;
	my $text = $self->token->text || $href;

	$self->_open_paragraph_if_not;
	$self->_append_html( qq|<a href="$href">$text</a>| );
}

# ------------------------------------------------------------------------------

sub handle_media {
	my ($self) = @_;

	my $src    = $self->token->src;
	my $width  = $self->token->width  ? ' width="'.$self->token->width.'"' : '';
	my $height = $self->token->height ? ' height="'.$self->token->height.'"' : '';	

	my $class  = '';
	if ($_ = $self->token->align) {
		/^left$/    && do { $class=' class="pulled-left"' };
		/^right$/   && do { $class=' class="pulled-right"' };
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

sub handle_row {
    my ($self) = @_;
    
	$self->_finalise_paragraph_if_open;

    # If not already in row context then start caching the output
    unless ( $self->in_row ) {
        $self->in_row(true);
        $self->current_row({
            content => '',
            columns => 1,
        });
    }
    else {
        $self->in_row(false);
        $self->_append_html(
            '<div class="clearfix row-'
            .$self->current_row->{columns}
            .'"><span class="column">'
            .$self->current_row->{content}
            .'</span></div>'
        );
    }
}

# ------------------------------------------------------------------------------

sub handle_columndivider {
    my ($self) = @_;

    unless ($self->in_row) {
        # Ignore outside of a row!
        return;
    }
    $self->current_row->{columns}++;
    $self->_finalise_paragraph_if_open;
    $self->_append_html( '</span><span class="column">' );
}

# ------------------------------------------------------------------------------

sub handle_linebreak {
	my ($self) = @_;
	trace "Handle LINE BREAK" [HTML];
	$self->_append_html('<br>');
}

# ------------------------------------------------------------------------------

sub handle_paragraphbreak {
	my ($self) = @_;
	trace "Handle PARAGRAPH BREAK" [HTML];
	$self->_finalise_paragraph_if_open;	
}

# ------------------------------------------------------------------------------

sub parse_end {
	my ($self) = @_;
    $self->_finalise_paragraph_if_open;
}

# ------------------------------------------------------------------------------

sub _append_html {
	my ($self, $append) = @_;
    if ($self->in_row) {
    	$self->current_row->{content} = $self->current_row->{content} . $append;
    }
    else {
    	$self->_set_html( $self->html . $append );
    }
}

# ------------------------------------------------------------------------------

sub _finalise_paragraph_if_open {
    my ($self) = @_;
    if ($self->in_paragraph) {
        $self->_append_html( $PARAGRAPH_END );
        $self->in_paragraph(false);
    }
}

# ------------------------------------------------------------------------------

sub _open_paragraph_if_not {
    my ($self) = @_;
    unless ($self->in_paragraph) {
        $self->_append_html( $PARAGRAPH_START );
        $self->in_paragraph(true);
    }
}

# ------------------------------------------------------------------------------

1;
