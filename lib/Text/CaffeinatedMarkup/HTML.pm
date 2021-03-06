package Text::CaffeinatedMarkup::HTML;

use strict;
use v5.10;
use Moo;
extends 'Text::CaffeinatedMarkup::PullParser';

use Log::Declare;
use boolean;

# To implement
# * data list
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

has in_list_item       => ( is => 'rw' );
has current_list_level => ( is => 'rw' );

has list_stack	=> ( is => 'rw' );

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
    $self->in_list_item(false);
    $self->current_list_level(0);

    $self->list_stack([]);

	info "Starting with HTML [%s]", $self->html;

	$self->tokenize( $cml );

	# Finalise
	$self->_finalise_paragraph_if_open;	

	$self->_finalise_lists;

	return $self->html;
}

# ------------------------------------------------------------------------------

sub handle_listitem {
	my ($self) = @_;

	my $type  = $self->token->type;
	my $level = $self->token->level;

	trace "Handle LIST ITEM [%s] at [%s]", $type, $level [HTML];

	# Examine the current level (if there is one).
	# If we're higher then push a new level onto the stack, if the same
	# then just handle the item, and if lower then pop from the stack.
	if (!scalar @{$self->list_stack}) {
		# No current stack - create list and handle item
		# New list
		$self->_append_html( $type eq 'unordered' ? '<ul>' : '<ol>' );
		unshift @{$self->list_stack}, {level=>$level,type=>$type};

		$self->in_list_item(true);
		$self->_append_html('<li class="cml-list-item">');	
	}
	else {
		my $last_level = $self->list_stack->[0]->{level};
		$self->_close_list_item_if_open;
		

		if ($level > $last_level) {
			# Go deeper!					
			
			$self->_append_html( $type eq 'unordered' ? '<ul>' : '<ol>' );
			unshift @{$self->list_stack}, {level=>$level,type=>$type};			

			$self->_append_html('<li class="cml-list-item">');
			$self->in_list_item(true);
			
		}
		elsif ($level < $last_level) {
			# Come up!
			# ...
			my $closing = shift @{$self->list_stack};

			$self->_append_html( $closing->{type} eq 'unordered' ? '</ul>' : '</ol>' );
			$self->_append_html('<li class="cml-list-item">');
			$self->in_list_item(true);

		}
		else {
			# Same level
			$self->_close_list_item_if_open;
			$self->in_list_item(true);
			$self->_append_html('<li class="cml-list-item">');
		}
	}
}

# ------------------------------------------------------------------------------

sub handle_blockquote {
	my ($self) = @_;

	trace "Handle BLOCKQUOTE", [HTML];

	if ($self->in_block_quote) {
		$self->_finalise_paragraph_if_open;
		$self->_append_html('</blockquote>');
		$self->in_block_quote(false);
	}
	else {
		$self->_append_html('<blockquote class="cml-blockquote">');
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
	$self->_append_html( $self->$access ? "</$tag>" : "<$tag class=\"cml-$tag\">" );
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

	$self->_finalise_paragraph_if_open;

	my $src    = $self->token->src;
	my $width  = $self->token->width  ? ' width="'.$self->token->width.'"' : '';
	my $height = $self->token->height ? ' height="'.$self->token->height.'"' : '';	
	my $caption= $self->token->caption;

	my $class  = '';
	if ($_ = $self->token->align) {
		/^left$/    && do { $class=' cml-pulled-left' };
		/^right$/   && do { $class=' cml-pulled-right' };
		/^stretch$/ && do { $class=' cml-stretch' };
		/^center$/  && do { $class=' cml-center' };
	}

	if (defined $caption) {
		$self->_append_html('<figure>');
	}

	$self->_append_html(qq|<img class="cml-img$class" src="$src"$width$height>|);

	if (defined $caption) {
		$self->_append_html(qq|<figcaption>$caption</figcaption>|);
		$self->_append_html('</figure>');
	}
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
            '<div class="clearfix cml-row cml-row-'
            .$self->current_row->{columns}
            .'"><span>'
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
    $self->_append_html( '</span><span>' );
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
	$self->_close_list_item_if_open;
	$self->_finalise_lists;
	$self->_finalise_paragraph_if_open;	
}

# ------------------------------------------------------------------------------

sub handle_spacer {
	my ($self) = @_;
	$self->_append_html('<div class="cml-spacer">&nbsp;</div>');
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
        trace "Closed paragraph" [HTML PARAGRAPH];
    }
}

# ------------------------------------------------------------------------------

sub _close_list_item_if_open {
	my ($self) = @_;
	if ($self->in_list_item) {
		$self->_finalise_paragraph_if_open;
		trace "Close current list item" [HTML LIST];
		$self->_append_html( '</li>' );
		$self->in_list_item(false);
	}
}

# ------------------------------------------------------------------------------

# Called to clean up any open lists
sub _finalise_lists {
	my ($self) = @_;

	$self->_close_list_item_if_open;

	while(@{$self->list_stack}) {
		my $close = shift @{$self->list_stack};
		trace "Finalise list [%s]", $close->{type} [HTML LIST];
		$self->_append_html( $close->{type} eq 'unordered' ? '</ul>' : '</ol>' );
	}	

}

# ------------------------------------------------------------------------------

sub _open_paragraph_if_not {
    my ($self) = @_;

    unless ($self->in_paragraph) {
        $self->_append_html( $PARAGRAPH_START );
        $self->in_paragraph(true);
        trace "Opened paragraph" [HTML PARAGRAPH];
    }
}

# ------------------------------------------------------------------------------

1;
