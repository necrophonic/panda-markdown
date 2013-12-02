package PML::PullParser;

use strict;
use warnings;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($TRACE);

use Moo;

has 'pml'				=> (is=>'rw');
has 'pml_chars'			=> (is=>'rw');
has 'num_pml_chars'		=> (is=>'rw');

has 'temporary_token'			=> (is=>'rw');
has 'temporary_token_context'	=> (is=>'rw');

has 'tokens'				=> (is=>'rw');
has 'has_finished_parsing'	=> (is=>'rw');
has 'pointer'				=> (is=>'rw');
has 'state'					=> (is=>'rw');

has 'token' => (is=>'rw'); # Output token


my $SYM_STRONG		= '*';
my $SYM_EMPHASIS	= '/';
my $SYM_UNDERLINE	= '_';
my $SYM_DELETE		= '-';

my $SYM_LINK_START				= '[';
my $SYM_LINK_END				= ']';
my $SYM_LINK_CONTEXT_SWITCH		= '|';

my $SYM_IMAGE_START				= '{';
my $SYM_IMAGE_END				= '}';
my $SYM_IMAGE_CONTEXT_SWITCH	= '|';

my $SYM_NEWLINE	= "\n";


# ------------------------------------------------------------------------------

sub BUILD {
	my ($self) = @_;

	die "Must supply 'pml' to ".__PACKAGE__."::new()\n\n" unless $self->pml;

	# Presplit the input before parsing	
	$self->pml_chars([split //,$self->pml]);
	$self->num_pml_chars( scalar @{$self->pml_chars} );

	# Initialise
	$self->tokens([]);
	$self->has_finished_parsing(0);

	$self->pointer(0);
	$self->state('data');

	return;
}

# ------------------------------------------------------------------------------

sub get_next_token {
	my ($self) = @_;

	return 0 if $self->has_finished_parsing;

	while(!$self->token) {
		my $state = $self->state;
		my $char = $self->pml_chars->[$self->pointer] || 'EOF';

		$self->_increment_pointer;
		TRACE "State is '$state'";
		TRACE "  Read char [ ".($char||'EOF')." ]";

		if ($state eq 'data') {

			if ($char eq $SYM_STRONG)   { $self->_switch_state('strong');    next; }
			if ($char eq $SYM_EMPHASIS) { $self->_switch_state('emphasis');  next; }
			if ($char eq $SYM_UNDERLINE){ $self->_switch_state('underline'); next; }
			if ($char eq $SYM_DELETE)	{ $self->_switch_state('delete');	 next; }

			if ($char eq $SYM_LINK_START) {
				$self->_switch_state('link-start');
				next;
			}

			if ($char eq $SYM_IMAGE_START) {
				$self->_switch_state('image-start');
				next;
			}

			if ($char eq $SYM_NEWLINE) {
				$self->_create_token({type=>'NEWLINE'});
				$self->_switch_state('newline');
				next;
			}

			if ($char eq 'EOF') {
				$self->_switch_state('end_of_data');
				next;
			}

			# "Anything else"
			# Append to string char, emitting if there was a
			# previous token that wasn't a string.
			my $previous_token = $self->_append_to_string_token( $char );
			next;
		}

		# ---------------------------------------

		if ($state eq 'strong') {

			if ($char eq $SYM_STRONG) {		
				$self->_create_token({type=>'STRONG'});
				$self->_switch_state('data');				
				next;
			}

			if ($char eq 'EOF') {
				$self->_append_to_string_token( $SYM_STRONG );
				$self->_switch_state('end_of_data');
				next;
			}

			# "Anything else"
			# Append a star (*) to the current string token, reconsume char
			# and switch to data state.
			$self->_append_to_string_token( $SYM_STRONG );
			$self->_decrement_pointer;
			$self->_switch_state('data');
			next;
		}

		# ---------------------------------------

		if ($state eq 'emphasis') {

			if ($char eq $SYM_EMPHASIS) {		
				$self->_create_token({type=>'EMPHASIS'});
				$self->_switch_state('data');				
				next;
			}

			if ($char eq 'EOF') {
				$self->_append_to_string_token( $SYM_EMPHASIS );
				$self->_switch_state('end_of_data');
				next;
			}

			# "Anything else"
			# Append a foreslash (/) to the current string token, reconsume char
			# and switch to data state.
			$self->_append_to_string_token( $SYM_EMPHASIS );
			$self->_decrement_pointer;
			$self->_switch_state('data');
			next;
		}

		# ---------------------------------------

		if ($state eq 'underline') {

			if ($char eq $SYM_UNDERLINE) {		
				$self->_create_token({type=>'UNDERLINE'});
				$self->_switch_state('data');				
				next;
			}

			if ($char eq 'EOF') {
				$self->_append_to_string_token( $SYM_UNDERLINE );
				$self->_switch_state('end_of_data');
				next;
			}

			# "Anything else"
			# Append an underscore (_) to the current string token, reconsume char
			# and switch to data state.
			$self->_append_to_string_token( $SYM_UNDERLINE );
			$self->_decrement_pointer;
			$self->_switch_state('data');
			next;
		}

		# ---------------------------------------

		if ($state eq 'delete') {

			if ($char eq $SYM_DELETE) {		
				$self->_create_token({type=>'DEL'});
				$self->_switch_state('data');				
				next;
			}

			if ($char eq 'EOF') {
				$self->_append_to_string_token( $SYM_DELETE );
				$self->_switch_state('end_of_data');
				next;
			}

			# "Anything else"
			# Append a dash (-) to the current string token, reconsume char
			# and switch to data state.
			$self->_append_to_string_token( $SYM_DELETE );
			$self->_decrement_pointer;
			$self->_switch_state('data');
			next;
		}

		# ---------------------------------------

		if ($state eq 'link-start') {

			if ($char eq $SYM_LINK_START) {
				$self->_create_token({type=>'LINK',href=>'',text=>''});
				$self->temporary_token_context('href');
				$self->_switch_state('link-href');
				next;
			}

			if ($char eq 'EOF') {
				$self->_append_to_string_token( $SYM_LINK_START );
				$self->_switch_state('end_of_data');
				next;
			}

			# "Anything else"
			# Append an open square bracket ([) to the current string token,
			# reconsume char and switch to data state.
			$self->_append_to_string_token( $SYM_LINK_START );
			$self->_decrement_pointer;
			$self->_switch_state('data');
			next;
		}

		# ---------------------------------------

		if ($state eq 'link-href') {

			if ($char eq $SYM_LINK_CONTEXT_SWITCH) { $self->_switch_state('link-text'); next }
			if ($char eq $SYM_LINK_END) 		   { $self->_switch_state('link-end');  next }
			
			if ($char eq 'EOF') {
				$self->_raise_parse_error("Unexpected 'EOF' while parsing link href");
			}

			# "Anything else"
			# Append to open link token href
			if ($self->temporary_token->{type} eq 'LINK') {
				$self->temporary_token->{href} .= $char;
				next;
			}

			# Oops
			$self->_raise_parse_error("Attempt to append link href data to non-link token");
		}

		# ---------------------------------------

		if ($state eq 'link-text') {

			if ($char eq $SYM_LINK_END) {
				$self->_switch_state('link-end');
				next;
			}

			if ($char eq 'EOF') {
				$self->_raise_parse_error("Unexpected 'EOF' while parsing link text");
			}

			# "Anything else"
			# Append to open link token href
			if ($self->temporary_token->{type} eq 'LINK') {
				$self->temporary_token->{text} .= $char;
				next;
			}

			# Oops
			$self->_raise_parse_error("Attempt to append link text data to non-link token");
		}

		# ---------------------------------------

		if ($state eq 'link-end') {

			if ($char eq $SYM_LINK_END) {
				$self->_switch_state('data');
				next;
			}

			if ($char eq 'EOF') {
				$self->_raise_parse_error("Unexpected 'EOF' while parsing link end");
			}

			# "Anything else"
			# Append to href or text depending on context
			my $context = $self->temporary_token_context;
			
			if ($context =~ /^(?:href|text)$/o) {
				$self->temporary_token->{$context} .= $char;
				next;
			}

			$self->_raise_parse_error("Missing or bad link token context");
		}

		# ---------------------------------------

		if ($state eq 'image-start') {

			if ($char eq $SYM_IMAGE_START) {
				$self->_create_token({type=>'IMAGE',src=>'',options=>''});
				$self->temporary_token_context('src');
				$self->_switch_state('image-src');
				next;
			}

			if ($char eq 'EOF') {
				$self->_append_to_string_token( $SYM_IMAGE_START );
				$self->_switch_state('end_of_data');
				next;
			}

			# "Anything else"
			# Append an open curly bracket ({}) to the current string token,
			# reconsume char and switch to data state.
			$self->_append_to_string_token( $SYM_IMAGE_START );
			$self->_decrement_pointer;
			$self->_switch_state('data');
			next;
		}

		# ---------------------------------------

		if ($state eq 'image-src') {

			if ($char eq $SYM_IMAGE_CONTEXT_SWITCH) { $self->_switch_state('image-options'); next }
			
			if ($char eq $SYM_IMAGE_END) {
				$self->_switch_state('image-end');
				next;
			}
			
			if ($char eq 'EOF') {
				$self->_raise_parse_error("Unexpected 'EOF' while parsing image src");
			}

			# "Anything else"
			# Append to open link token href
			if ($self->temporary_token->{type} eq 'IMAGE') {
				$self->temporary_token->{src} .= $char;
				next;
			}

			# Oops
			$self->_raise_parse_error("Attempt to append image src data to non-image token");
		}

		# ---------------------------------------

		if ($state eq 'image-options') {

			if ($char eq $SYM_IMAGE_END) {
				$self->_switch_state('image-end');
				next;
			}

			if ($char eq 'EOF') {
				$self->_raise_parse_error("Unexpected 'EOF' while parsing image options");
			}

			# "Anything else"
			# Append to open link token href
			if ($self->temporary_token->{type} eq 'IMAGE') {
				$self->temporary_token->{options} .= $char;
				next;
			}

			# Oops
			$self->_raise_parse_error("Attempt to append image options data to non-image token");
		}

		# ---------------------------------------

		if ($state eq 'image-end') {

			if ($char eq $SYM_IMAGE_END) {
				$self->_switch_state('data');
				next;
			}

			if ($char eq 'EOF') {
				$self->_raise_parse_error("Unexpected 'EOF' while parsing image end");
			}

			# "Anything else"
			# Append to src or options depending on context
			my $context = $self->temporary_token_context;
			
			if ($context =~ /^(?:src|options)$/o) {
				$self->temporary_token->{$context} .= $char;
				next;
			}

			$self->_raise_parse_error("Missing or bad image token context");
		}
		
		# ---------------------------------------

		if ($state eq 'newline') {

			if ($char eq 'EOF') {
				$self->_switch_state('end_of_data');
				next;
			}

			if ($char eq $SYM_NEWLINE) {
				$self->_create_token({type=>'NEWLINE'});				
				next;
			}

			if ($char eq ' ') {
				next;
			}

			# Anything else
			$self->_switch_state('data');
			$self->_decrement_pointer;
			next;
		}

		# ---------------------------------------

		if ($state eq 'end_of_data') {
			DEBUG "End of data reached - finish parse";
			$self->has_finished_parsing(1);
			$self->_emit_token;
			last;
		}

		# ---------------------------------------

		# Catch error to stop infinite looping
		if ($self->pointer > $self->num_pml_chars) {
			$self->_raise_parse_error("Overran end of data");
		}

	}

	my $token = $self->token || 0;

	$self->token(undef);

	return $token;
}

# ------------------------------------------------------------------------------

sub get_all_tokens {
	my ($self) = @_;	

	# Not finished parsing yet (or started at all) so get_next_token until 
	# we run out of document! Otherwise we just return what we have.
	unless ($self->has_finished_parsing) {
		while ($self->get_next_token) {}		
	}
	return wantarray ? @{$self->tokens} : $self->tokens;	
}

# ------------------------------------------------------------------------------

sub _increment_pointer { $_[0]->pointer( $_[0]->pointer + 1) }
sub _decrement_pointer { $_[0]->pointer( $_[0]->pointer - 1); TRACE "  -> Requeue char" }

# ------------------------------------------------------------------------------

# Emit the current "temporary token" if there is one.
# Doing this returns to the client as well as adding to the token bucket.
sub _emit_token {
	my ($self) = @_;

	return unless my $token = $self->temporary_token;
	push @{$self->tokens}, $token;

	# Reset the temporary token
	$self->temporary_token(undef);

	DEBUG "  >> Emit token [ ".$token->{type}.' ]';

	$self->token($token); # Mark the token for output;
	return;
}

# ------------------------------------------------------------------------------

sub _raise_parse_error {
	my ($self, $msg) = @_;
	ERROR "!!Parse error [$msg]";
	die "Encountered parse error [$msg]\n\n";
}

# ------------------------------------------------------------------------------

sub _switch_state {
	my ($self, $switch_to) = @_;
	TRACE "  Switching to state [ $switch_to ]";
	$self->state($switch_to);
}

# ------------------------------------------------------------------------------

# If there's a temporary token, get rid of it
sub _discard_token {
	my ($self) = @_;
	$self->temporary_token(undef);
	$self->temporary_token_context(undef);
	return;
}

# ------------------------------------------------------------------------------

# Append a given char to the current string token or, if there isn't one,
# create one (emitting existing tokens as appropriate)
#
# @param	char 	character to add
#
sub _append_to_string_token {
	my ($self, $char) = @_;

	TRACE "  Append [ $char ] to string token";

	# Look at the current temporary token (if there is one).
	my $tmp_token = $self->temporary_token;

	if ($tmp_token && $tmp_token->{type} eq 'STRING') {
		TRACE "  -> Has existing string token";
		$self->temporary_token->{content} .= $char;
		return; # Nothing to return
	}

	# Otherwise create a new token and return the previous one
	# if there was one.
	$self->_create_token({type=>'STRING',content=>$char});
	return;
}

# ------------------------------------------------------------------------------

# Create a new token in the temporary store. If a token already exists
# there then this method returns it.
#
# @param	tpken		initial token
# @returns	the old temporary token
#			before it was replaced
#			with the new one.
#
sub _create_token {
	my ($self, $token) = @_;

	$self->_raise_parse_error("No token data passed to _create_token()") unless $token;

	TRACE "  Create new token [ ".$token->{type}." ]";
	my $old_temporary_token = undef;

	if ($self->temporary_token) {			
		$self->_emit_token;
	}

	# Clear any current context
	$self->temporary_token_context(undef);

	$self->temporary_token( $token );
	return undef;
}

1;
