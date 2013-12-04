package PML::HTMLFormatter;

use v5.10;
use strict;
use warnings;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($TRACE);

use Moo;
use PML::PullParser;



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
);


has 'tag_stack' => (is=>'rw',default=>sub{[]});
has 'is_paragraph_open'	=> (is=>'rw');

sub format {
	my ($self, $pml) = @_;

	my $parser = PML::PullParser->new(pml => $pml);

	my @tokens = $parser->get_all_tokens;
	my $html   = '';

	$self->is_paragraph_open(0);
		
	foreach my $token (@tokens) {

		my $type = $token->{type};

		if ($type =~ /^(STRONG|EMPHASIS|UNDERLINE|DEL)$/o) {
			TRACE "Type [$1]";			
			$html .= $self->_match_tag($1);
			next;
		}

		if ($type eq 'LINK') {
			# TODO - target
			my $href = $token->{href};
			my $text = $token->{text} || $token->{href};
			$html .= qq|<a href="$href" target="_new">$text</a>|;
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
			
			$html .= '<img src="'.$token->{src}.'"'.$align.$width.$height.'>';
			next;
		}

		if ($type eq 'HEADER') {
			$html .= "\n<h".$token->{level}.'>'.$token->{text}.'</h'.$token->{level}.">\n";
			next;
		}

		if ($type eq 'STRING') {
			$html .= $self->_open_paragraph unless $self->is_paragraph_open;
			$html .= $token->{content};
			next;
		}

		# Shouldn't get here!
		# TODO error

	}

	# If there's a paragraph open, close it!
	$html .= $tags{PARAGRAPH_CLOSE} if $self->is_paragraph_open;

	return $html;
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
	return $tags{PARAGRAPH_CLOSE};
}

1;
