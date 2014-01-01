package PML::HTMLFormatter;

use v5.10;
use strict;
use warnings;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($OFF);

use Moo;
use PML::PullParser;
use HTML::Escape qw/escape_html/;


my %tags = (
	STRONG_OPEN		=> '<strong>',
	STRONG_CLOSE 	=> '</strong>',
	EMPHASIS_OPEN	=> '<em>',
	EMPHASIS_CLOSE 	=> '</em>',
	UNDERLINE_OPEN	=> '<u>',
	UNDERLINE_CLOSE => '</u>',
	DEL_OPEN		=> '<del>',
	DEL_CLOSE	 	=> '</del>',

	PARAGRAPH_OPEN 	=> '<p>',
	PARAGRAPH_CLOSE	=> '</p>',

	BLOCKQUOTE_OPEN	=> '<blockquote>',
	BLOCKQUOTE_CLOSE=> '</blockquote>',

	BLOCKQUOTE_CITE_OPEN	=> '<cite>',
	BLOCKQUOTE_CITE_CLOSE	=> '</cite>',
);


has 'tag_stack'				=> (is=>'rw',default=>sub{[]});
has 'is_paragraph_open'		=> (is=>'rw');
has 'num_breaks'			=> (is=>'rw');

has 'is_in_row'				=> (is=>'rw');
has 'is_in_column'			=> (is=>'rw');
has 'row_has_num_columns'	=> (is=>'rw');
has 'row_columns'			=> (is=>'rw');

sub format {
	my ($self, $pml) = @_;

	my $parser = PML::PullParser->new(pml => $pml);

	my @tokens = $parser->get_all_tokens;
	
	my $output_html 	= '';
	my $cur_column_html = '';
	my $html   			= \$output_html;

	$self->num_breaks(0);

	$self->is_paragraph_open(0);
	$self->is_in_row(0);
	$self->row_has_num_columns(-1);
	$self->row_columns([]);	
		
	foreach my $token (@tokens) {

		my $type = $token->{type};

		if ($type eq 'NEWLINE') {
			# Start storing breaks. We output as soon as we get something different
			# (see the else). If there's only one then you get a BR, otherwise you
			# get a paragraph.
			$self->num_breaks( $self->num_breaks+1 );
			next;			
		}
		else {
			unless ($type eq 'HEADER') {

				if ($self->num_breaks == 1) {
					$$html .= '<br>';
				}
				elsif ($self->num_breaks > 1) {
					$$html .= $self->_close_paragraph if $self->is_paragraph_open;
					$$html .= $self->_open_paragraph;
				}
			}
			$self->num_breaks(0);
		}

		if ($type eq 'QUOTE') {

			$self->_close_paragraph if $self->is_paragraph_open;

			$$html .= $tags{BLOCKQUOTE_OPEN};
			$$html .= $token->{body};

			if ($token->{cite}) {
				$$html .= $tags{BLOCKQUOTE_CITE_OPEN}.$token->{cite}.$tags{BLOCKQUOTE_CITE_CLOSE};
			}

			$$html .= $tags{BLOCKQUOTE_CLOSE};
		}

		if ($type eq 'ROW') {			
			if ($self->is_in_row) {
				# Finalise row

				if ($self->is_in_column) {
					$cur_column_html .= $self->_close_paragraph if $self->is_paragraph_open;					
					# Already in a column, so output it to the column store				
					push @{$self->row_columns}, $cur_column_html;
					$cur_column_html = '';	
				}

				$html = \$output_html;

				my $num_columns = $self->_num_columns_in_cur_row;



				$$html .= '<div class="clearfix col-'.$num_columns.'">'."\n";

				foreach my $column (@{$self->row_columns}) {
					$$html .= '<div class="column">' . "\n$column" . "</div>\n";					
				}

				$$html .= "</div>\n"; # End of row

				# Reset the columns when we close out the row rather than
				# when starting so that you can always query "num columns"
				# and it will be right in context for wherever the parsing is.
				$self->row_columns([]);
				$self->is_in_column(0);
				$self->is_in_row(0);
				
			}
			else {				
				$$html .= $self->_close_paragraph if $self->is_paragraph_open;
				$self->is_in_row(1);
			}
			next;
		}

		if ($type eq 'COLUMN') {			
			# TODO error if not in row!			
			$html = \$cur_column_html;		

			if ($self->is_in_column) {
				$cur_column_html .= $self->_close_paragraph if $self->is_paragraph_open;				
				# Already in a column, so output it to the column store				
				push @{$self->row_columns}, $cur_column_html;
				$cur_column_html = '';	
			}
						
			$self->is_in_column(1);
			$self->row_has_num_columns( $self->row_has_num_columns+1 );			
		}

		if ($type =~ /^(STRONG|EMPHASIS|UNDERLINE|DEL)$/o) {
			TRACE "Type [$1]";			
			$$html .= $self->_match_tag($1);
			next;
		}

		if ($type eq 'LINK') {
			# TODO - target
			my $href = $token->{href};
			my $text = $token->{text} || $token->{href};
			$$html .= qq|<a href="$href" target="_new">$text</a>|;
			next;
		}

		if ($type eq 'IMAGE') {
			my @options;
			if ($token->{options}) {				
				@options = split /,/,$token->{options};				
			}			

			my $align  = '';
			my $height = '';
			my $width  = '';

			foreach my $option (@options) {
				$align = ' class="pulled-left"'  if $option eq '<<';
				$align = ' class="pulled-right"' if $option eq '>>';
				$align = ' class="stretched"'    if $option eq '<>';
				$align = ' class="centered"'     if $option eq '><';

				if ($option =~ /^H(.+)$/) { $height = qq| height="$1px"| }
				if ($option =~ /^W(.+)$/) { $width  = qq| width="$1px"|  }
			}
			
			$$html .= '<img src="'.$token->{src}.'"'.$align.$width.$height.'>';
			next;
		}

		if ($type eq 'HEADER') {
			$$html .= "\n<h".$token->{level}.'>'.$token->{text}.'</h'.$token->{level}.">\n";
			next;
		}

		if ($type eq 'STRING') {
			$$html .= $self->_open_paragraph unless $self->is_paragraph_open;
			$$html .= escape_html($token->{content});
			next;
		}



		# Shouldn't get here!
		# TODO error

	}

	# If there's a paragraph open, close it!
	$output_html .= $tags{PARAGRAPH_CLOSE} if $self->is_paragraph_open;

	return $output_html;
}

# ------------------------------------------------------------------------------

sub _num_columns_in_cur_row {
	my ($self) = @_;
	return scalar @{$self->row_columns};
}

# ------------------------------------------------------------------------------

sub _match_tag {
	my ($self, $type) = @_;

	if (@{$self->tag_stack} && $self->tag_stack->[0] eq $type) {		
		# Close tag
		$self->_pop_stack;
		return $tags{$type."_CLOSE"};
	}
	else {		
		# Open tag
		my $html = '';		
		# If a paragraph isn't open then we need to open one!
		$html = $self->_open_paragraph unless $self->is_paragraph_open;		
		$self->_push_stack($type);
		return $html . $tags{$type."_OPEN"};
	}
	return;
}

# ------------------------------------------------------------------------------

sub _push_stack {
	my ($self, $type) = @_;
	unshift @{$self->tag_stack}, $type;
}

# ------------------------------------------------------------------------------

sub _pop_stack {
	my ($self) = @_;
	return shift @{$self->tag_stack};
}

# ------------------------------------------------------------------------------

sub _open_paragraph {
	my ($self) = @_;
	die "Can't open paragraph - already open!" if $self->is_paragraph_open;
	$self->_push_stack('PARAGRAPH');
	$self->is_paragraph_open(1);
	return $tags{PARAGRAPH_OPEN};
}

# ------------------------------------------------------------------------------

sub _close_paragraph {
	my ($self) = @_;
	die "Can't close paragraph - already closed!" unless $self->is_paragraph_open;
	die "Can't close paragraph - bad stack match" unless $self->tag_stack->[0] eq 'PARAGRAPH';
	$self->_pop_stack;
	$self->is_paragraph_open(0);
	return $tags{PARAGRAPH_CLOSE}."\n";
}

1;
