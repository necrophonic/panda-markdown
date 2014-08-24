package Text::CaffeinatedMarkup::PullParser;

use strict;
use v5.10;
use boolean;
use Moo;

use Log::Declare;

use Text::CaffeinatedMarkup::PullParser::ParagraphBreakToken;
use Text::CaffeinatedMarkup::PullParser::ColumnDividerToken;
use Text::CaffeinatedMarkup::PullParser::BlockQuoteToken;
use Text::CaffeinatedMarkup::PullParser::LineBreakToken;
use Text::CaffeinatedMarkup::PullParser::EmphasisToken;
use Text::CaffeinatedMarkup::PullParser::DividerToken;
use Text::CaffeinatedMarkup::PullParser::HeaderToken;
use Text::CaffeinatedMarkup::PullParser::MediaToken;
use Text::CaffeinatedMarkup::PullParser::TextToken;
use Text::CaffeinatedMarkup::PullParser::LinkToken;
use Text::CaffeinatedMarkup::PullParser::RowToken;


# TODO check eof error states

# To implement
# * block quote
# * spacers
# * list
# * table
# * block code
# * inline code

has 'state_stack' => ( is => 'rwp' );
has 'chars'   => ( is => 'rwp' );
has 'pointer' => ( is => 'rwp' );
has 'token'   => ( is => 'rwp' );
has 'tokens'  => ( is => 'rwp', default => sub{[]} );
has 'indent'  => ( is => 'rwp' );

has 'in_row_context'    => ( is => 'rwp' );
has 'is_block_escaping' => ( is => 'rwp' );
has 'is_block_quoting'  => ( is => 'rwp' );

# ------------------------------------------------------------------------------

sub BUILD {
	my ($self) = @_;
	debug "Created new parser";
	return;
}

# ------------------------------------------------------------------------------

sub _emit_token {
	my ($self) = @_;
	# Call the appropriate handler
	(my $method = ref $self->token) =~ s/(?:.*)\::(.+?)Token/handle_\L$1/;	
	debug "Calling [%s]", $method [TOKENIZE];
	$self->token->finalise;

	$self->$method();
	$self->_set_token(undef);
}

# ------------------------------------------------------------------------------

sub parse_end {
	my ($self) = @_;
	# Override in child
}

# -----------------------------------------------------------------------------

sub tokenize {
    my ($self, $cml) = @_;	

    trace "Tokenize [$cml]" [TOKENIZE];

	# init
    $self->_set_tokens([]);
    $self->_set_chars([split//,$cml]);
    $self->_set_pointer(-1);
    $self->_set_token(undef);
    $self->_set_state_stack(['newline','none']);
    $self->_set_in_row_context(false);
    $self->_set_is_block_escaping(false);
    $self->_set_indent(0);

	while ( $self->pointer < $#{$self->chars} ) {

		trace "LOOP" [TOKENIZE];

		$self->_inc_pointer;

		my $state = $self->_state;
		my $char  = $self->chars->[$self->pointer];

		debug "Get next with state [%s], char [%s] (%s)", $state||'no state', $char||'no char', $self->pointer [TOKENIZE];		

		if ($state eq 'none') {
			if ($self->is_block_escaping) {

				if ($char eq '%') {
					if (!defined $self->_peek) { #eof
						$self->_push_state('eof');
						$self->_create_token('text');
						$self->token->append_content('%');
					}
					else {
						$self->_toggle_escape;					
						$self->_inc_pointer;
					}
					next;
				}

				$self->_push_state('text');
				$self->_create_token('text');
				$self->token->append_content($char);
				next;
			}

			if ($char eq "\\") {
				if (!defined $self->_peek) { # eof
					$self->_push_state('eof');
					$self->_create_token('text');
					$self->token->append_content("\\");
				}
				else {
					$self->_push_state('text');
					$self->_create_token('text');
					$self->tokenize->append_content( $self->_peek );
					$self->_inc_pointer;
				}
				next;
			}
			if ($char eq '%') {
				if (!defined $self->_peek) { #eof
					$self->_push_state('eof');
					$self->_create_token('text');
					$self->token->append_content('%');
				}
				else {
					$self->_toggle_escape;					
					$self->_inc_pointer;
				}
				next;
			}

			if ($char eq '"' && $self->_peek_match($char)) {
				$self->_create_and_emit_token('block_quote');
				$self->_set_is_block_quoting( !$self->is_block_quoting );
				next;
			}

			if ($char eq '#') {				
				my $consumed = $self->_consume_until(' ');
				$self->_create_token('header');
				$self->token->level($consumed);
                trace "Set header level to [%s]",$consumed [TOKENIZE];
				$self->_inc_pointer;
				$self->_push_state('header');
				next;
			}

			if ($char =~ /[\*\/_]/ && $self->_peek_match($char)) {										
				$self->_create_and_emit_token($char);					
                next;
			}

			if ($char eq '[' && $self->_peek_match($char)) {
				$self->_push_state('link_href');
				$self->_create_token('link');
                next;
			}

			if ($char eq '{' && $self->_peek_match($char)) {
				$self->_push_state('media_src');
				$self->_create_token('media');
                next;
			}

            if ($char eq "\n") {
                $self->_push_state('newline');
                $self->_set_indent(0);
                next;
            }

			# Anything else
			$self->_push_state('text');
			$self->_create_token('text');
			$self->token->append_content($char);
			next;
		}

		# --------------------------------------------------

		if ($state eq 'newline') {
			if ($self->is_block_escaping) {
				if ($char eq '%') {
					if (!defined $self->_peek) { #eof
						$self->_switch_state('eof');
						$self->_create_token('text');
						$self->token->append_content('%');
					}
					else {
						$self->_toggle_escape;
						$self->_inc_pointer;
					}
					next;
				}

				$self->_switch_state('text');
				$self->_create_token('text');
				$self->token->append_content($char);
				next;
			}

			if ($char eq "\\") {				
				my $next_char = $self->_peek;
				if (!defined $next_char) { # eof
					$self->_switch_state('eof');
					$self->_create_token('text');
					$self->token->append_content("\\");
				}
				else {
					$self->_switch_state('text');
					$self->_create_token('text');					
					$self->token->append_content( $next_char );
					$self->_inc_pointer;					
				}
				next;
			}
			if ($char eq '%') {
				if (!defined $self->_peek) { #eof
					$self->_switch_state('eof');
					$self->_create_token('text');
					$self->token->append_content('%');
				}
				else {
					$self->_toggle_escape;
					$self->_inc_pointer;
				}
				next;
			}

			if ($char eq ' ') {
				$self->_set_indent($self->indent+1);
				next;
			}

			if ($char eq '"' && $self->_peek_match($char)) {
				$self->_create_and_emit_token('block_quote');
				$self->_set_is_block_quoting( !$self->is_block_quoting );
				next;
			}

            if ($char eq '=') {
                if ($self->_peek_match($char)) {

                    $self->_discard_token;

                    if ($self->in_row_context) {
                        # Already in a row, so this is the end
                        $self->_create_and_emit_token('row_end');
                        $self->_set_in_row_context(false);
                    }
                    else {
                        # Not in a row, so starting
                        $self->_create_and_emit_token('row_start');
                        $self->_set_in_row_context(true);
                    }

                    # Whether starting or ending we want to ignore
                    # the rest of the line
                    $self->_consume_until("\n");
                    $self->_inc_pointer;
                    next;
                }
                # Fall through to "anything else"
            }

            if ($char eq '-' && $self->in_row_context && $self->_peek_match($char)) {
                $self->_discard_token;
                $self->_create_and_emit_token('column_divider');
                $self->_consume_until("\n");
                $self->_inc_pointer;
                next;
            }

			if ($char eq "\n") {
				$self->_discard_token;
				$self->_create_and_emit_token('paragraph_break');
				$self->_pop_state;
				$self->_consume_until_not("\n");
				$self->_set_indent(0);
				next;				
			}

			if ($char eq '#') {				
				my $consumed = $self->_consume_until(' ');
				$self->_create_token('header');
				$self->token->level($consumed);
                trace "Set header level to [%s]",$consumed [TOKENIZE];
				$self->_inc_pointer;
				$self->_switch_state('header');
				next;
			}

			if ($char =~ /[\*\/_]/ && $self->_peek_match($char)) {
				$self->_create_and_emit_token($char);					
				$self->_pop_state;
                next;
			}

			if ($char eq '~' && $self->_peek_match($char)) {
				$self->_create_and_emit_token('div');
				$self->_consume_until("\n");
				$self->_inc_pointer; # Skip the newline!					
                next;
			}

			if ($char eq '[' && $self->_peek_match($char)) {
				$self->_switch_state('link_href');
				$self->_create_token('link');					
                next;
			}

			if ($char eq '{' && $self->_peek_match($char)) {
				$self->_switch_state('media_src');
				$self->_create_token('media');					
                next;
			}

			# Anything else
			$self->_switch_state('text');
			$self->_create_token('text');
			$self->token->append_content($char);
			next;
		}

		# --------------------------------------------------

		if ($state eq 'text') {
			if ($self->is_block_escaping) {
				if ($char eq '%') {				
					my $next_char = $self->_peek;
					if (!defined $next_char) { # eof
						$self->_switch_state('eof');					
						$self->token->append_content('%');
					}
					else {					
						$self->_toggle_escape;
						$self->_inc_pointer;
					}
					next;
				}	

				$self->token->append_content($char);
				next;
			}

			if ($char eq "\\") {				
				my $next_char = $self->_peek;
				if (!defined $next_char) { # eof
					$self->_switch_state('eof');					
					$self->token->append_content("\\");
				}
				else {			
					trace "Escape next char [%s]", $next_char [TOKENIZE];
					$self->token->append_content( $next_char );
					$self->_inc_pointer;
				}
				next;
			}		
			if ($char eq '%') {				
				my $next_char = $self->_peek;
				if (!defined $next_char) { # eof
					$self->_switch_state('eof');					
					$self->token->append_content('%');
				}
				else {					
					$self->_toggle_escape;
					$self->_inc_pointer;
				}
				next;
			}		

			if ($char eq "\n") {
				$self->_create_token('line_break');
				$self->_switch_state('newline');
				$self->_set_indent(0);
				next;
			}

			if ($char eq '"' && $self->_peek_match($char)) {
				$self->_create_and_emit_token('block_quote');
				$self->_set_is_block_quoting(false);
				next;
			}
			
			if ($char =~ /[\*\/_]/) {
				if ($self->_peek_match($char)) {
					$self->_pop_state;
					$self->_create_and_emit_token($char);
				}
				else {
					$self->token->append_content($char);
				}
				next;
			}

			if ($char eq '[') {
				if ($self->_peek_match($char)) {
					$self->_switch_state('link_href');
					$self->_create_token('link');
				}
				else {
					$self->token->append_content($char);
				}
				next;
			}

			if ($char eq '{') {
				if ($self->_peek_match($char)) {
					$self->_push_state('media_src');
					$self->_create_token('media');
				}
				else {
					$self->token->append_content($char);
				}
				next;
			}

			# Anything else
			$self->token->append_content($char);
			next;
		}

		# --------------------------------------------------

		if ($state eq 'link_href') {
			if ($char eq ']') {
				if (!defined $self->_peek) {
					die "Unexpected end of file"; # TODO parse_error
				}
				elsif ($self->_peek_match($char)) {					
					$self->_emit_token;
					$self->_pop_state;
				}
				else {
					$self->token->append_href($char)
				}
				next;
			}

			if ($char eq '|') {
				$self->_switch_state('link_text');
				next;
			}

			# Anything else
			$self->token->append_href($char);
			next;
		}

		# --------------------------------------------------

		if ($state eq 'link_text') {
			if ($char eq ']') {
				if (!defined $self->_peek) {
					die "Unexpected end of file"; # TODO parse_error
				}
				elsif ($self->_peek_match($char)) {					
					$self->_emit_token;
					$self->_pop_state;
				}
				else {
					$self->token->append_text($char)
				}
				next;
			}

			# Anything else
			$self->token->append_text($char);
			next;
		}

		# --------------------------------------------------

		if ($state eq 'media_src') {
			if ($char eq '}') {
				if (!defined $self->_peek) {
					die "Unexpected end of file"; # TODO parse_error
				}
				elsif ($self->_peek_match($char)) {					
					$self->_emit_token;
					$self->_pop_state;
				}
				else {
					$self->token->append_href($char)
				}
				next;
			}

			if ($char eq '|') {
				$self->_switch_state('media_options');
				next;
			}

			# Anything else
			$self->token->append_src($char);
			next;
		}

		# --------------------------------------------------

		if ($state eq 'media_options') {
			if ($char eq '}') {
				if (!defined $self->_peek) {
					die "Unexpected end of file"; # TODO parse_error
				}
				elsif ($self->_peek_match($char)) {					
					$self->_emit_token;
					$self->_pop_state;
				}
				else {
					$self->token->append_options($char)
				}
				next;
			}

			# Anything else
			$self->token->append_options($char);
			next;
		}

		# --------------------------------------------------

		if ($state eq 'header') {
			if (! defined $char) {
				die "Unexpected end of file";
			}

			if ($char eq "\n") {
				$self->_emit_token;
				$self->_switch_state('newline');
				$self->_set_indent(0);
			}
			else {
				$self->token->append_content($char);
			}
			next;
		}

		# --------------------------------------------------

	}
	$self->_emit_token if $self->token;
	$self->parse_end;
	return $self;
}

# ------------------------------------------------------------------------------

sub _inc_pointer { return ++$_[0]->{pointer} }
sub _dec_pointer { return --$_[0]->{pointer} }

# ------------------------------------------------------------------------------

sub _create_token {
	my ($self, $requested) = @_;

	$self->_emit_token if $self->token;	# Emit any existing token
	
	my $t;
	$_ = $requested;
	/^text$/            && do { $t = Text::CaffeinatedMarkup::PullParser::TextToken->new };
	/^\*$/              && do { $t = Text::CaffeinatedMarkup::PullParser::EmphasisToken->new('strong') };
	/^\/$/              && do { $t = Text::CaffeinatedMarkup::PullParser::EmphasisToken->new('emphasis') };
	/^_$/               && do { $t = Text::CaffeinatedMarkup::PullParser::EmphasisToken->new('underline') };
	/^-$/               && do { $t = Text::CaffeinatedMarkup::PullParser::EmphasisToken->new('delete') };
	/^\+$/              && do { $t = Text::CaffeinatedMarkup::PullParser::EmphasisToken->new('insert') };
	/^link$/            && do { $t = Text::CaffeinatedMarkup::PullParser::LinkToken->new };
	/^media$/           && do { $t = Text::CaffeinatedMarkup::PullParser::MediaToken->new };
	/^div$/             && do { $t = Text::CaffeinatedMarkup::PullParser::DividerToken->new };
	/^header$/          && do { $t = Text::CaffeinatedMarkup::PullParser::HeaderToken->new };	
	/^line_break$/      && do { $t = Text::CaffeinatedMarkup::PullParser::LineBreakToken->new };
    /^row_(start|end)$/ && do { $t = Text::CaffeinatedMarkup::PullParser::RowToken->new($1) };
    /^column_divider$/  && do { $t = Text::CaffeinatedMarkup::PullParser::ColumnDividerToken->new };
	/^paragraph_break$/ && do { $t = Text::CaffeinatedMarkup::PullParser::ParagraphBreakToken->new };	
	/^block_quote$/     && do { $t = Text::CaffeinatedMarkup::PullParser::BlockQuoteToken->new };	

	if ($t) {
		trace "Created new token [%s] [%s]", $requested, r:$t [TOKENIZE];
		return $self->_set_token( $t );
	}

	die "Unknown token type '$requested'";
}

# ------------------------------------------------------------------------------

sub _create_and_emit_token {
	my ($self, $requested) = @_;
	$self->_create_token($requested);
	$self->_emit_token;
	return;
}

# ------------------------------------------------------------------------------

sub _discard_token {
	my ($self) = @_;
	trace "Discarding token [%s]", r:$self->token [TOKENIZE];
	$self->_set_token(undef);
	return;
}

# ------------------------------------------------------------------------------

# Consume any number of chars until the specified one is reached.
sub _consume_until {
	my ($self, $delimit) = @_;
	my $char = $self->chars->[$self->_inc_pointer];
	debug "Consume until [%s]", $delimit [TOKENIZE CONSUME_UNTIL];
	my $consumed = 1;
	while($char && $char ne $delimit) {
		$consumed++;		
		trace "... ignore [%s]", $char [TOKENIZE CONSUME_UNTIL];
		$char = $self->chars->[$self->_inc_pointer];
	}
	trace "... consumed ($consumed)!" [TOKENIZE CONSUME_UNTIL];	
	$self->_dec_pointer;
	return $consumed;
}

# ------------------------------------------------------------------------------

sub _consume_until_not {
	my ($self, $delimit) = @_;
	my $char = $self->chars->[$self->_inc_pointer];
	debug "Consume until [%s]", $delimit [TOKENIZE CONSUME_UNTIL];
	my $consumed = 1;
	while($char && $char eq $delimit) {
		$consumed++;		
		trace "... ignore [%s]", $char [TOKENIZE CONSUME_UNTIL];
		$char = $self->chars->[$self->_inc_pointer];
	}
	trace "... consumed ($consumed)!" [TOKENIZE CONSUME_UNTIL];	
	$self->_dec_pointer;
	return $consumed;
}

# ------------------------------------------------------------------------------

sub _toggle_escape {
	my ($self) = @_;
	trace "Toggle escape to [%s]", $self->is_block_escaping?'off':'on' [TOKENIZE];
	$self->_set_is_block_escaping( !$self->is_block_escaping );
}

# ------------------------------------------------------------------------------

sub _peek {
	my ($self) = @_;

	if (($self->pointer + 1) > $#{$self->chars}) {
		# Attempt to peek over end of content		
		$self->_parse_error('unexpected eof');
	}
	return $self->chars->[$self->pointer+1];
}

# ------------------------------------------------------------------------------

sub _peek_match {
	my ($self, $char) = @_;
	trace "Peeked [%s] from [%s]", $self->_peek, $char [TOKENIZE];
	if ($self->_peek eq $char) {
		$self->_inc_pointer; # Skip over the matched char
		return 1;
	}
	return 0;	
}

# ------------------------------------------------------------------------------

sub _parse_error {
	my ($self,$message) = @_;
	die sprintf "PARSE ERROR AT CHAR (%d): %s\n\n",$self->pointer,$message;
}

# ------------------------------------------------------------------------------

sub _look_behind {
	my ($self) = @_;
	return $self->state_stack->[1]; # Look at the state behind the current head
}

# ------------------------------------------------------------------------------

sub _state {
	my ($self) = @_;
	return $self->state_stack->[0];		
}

# ------------------------------------------------------------------------------

sub _pop_state  {
	my ($self) = @_;
	my $top = shift @{$self->state_stack};
	debug "Pop state [%s], head now [%s]", $top, $self->state_stack->[0]||'' [STATE];

	# If the head is now 'text' then create a new text token
	if ($self->state_stack->[0] eq 'text') {
		$self->_create_token('text');
	}

	return $top;
}

# ------------------------------------------------------------------------------

sub _push_state {
	my ($self, $char) = @_;
	unshift @{$self->state_stack}, $char;
	debug "Push stack, head is now [%s]", $self->state_stack->[0] [STATE];
	return;
}

# ------------------------------------------------------------------------------

sub _switch_state {
	my ($self,$new_state) = @_;
	$self->state_stack->[0] = $new_state;
	debug "Switch state to [%s]", $new_state [STATE];
	return;
}

# ------------------------------------------------------------------------------

my $all = sub {
	my ($self) = @_;
	push @{$self->tokens}, $self->token;		
	$self->_set_token(undef);
};

sub handle_text 		  {$all->($_[0])};
sub handle_emphasis 	  {$all->($_[0])};
sub handle_link 		  {$all->($_[0])};
sub handle_media 		  {$all->($_[0])};
sub handle_divider 		  {$all->($_[0])};
sub handle_header 		  {$all->($_[0])};
sub handle_linebreak      {$all->($_[0])};
sub handle_paragraphbreak {$all->($_[0])};
sub handle_row  		  {$all->($_[0])};
sub handle_columndivider  {$all->($_[0])};
sub handle_blockquote	  {$all->($_[0])};

1;
