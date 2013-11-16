package PML::Tokenizer;

use v5.10;

use strict;
use warnings;
use boolean;

#use Log::Log4perl qw(:easy);
#Log::Log4perl->easy_init($DEBUG);

use Moo;

has 'pml'	=> ( is => 'rw' );
has 'chars'	=> ( is => 'rw' );

has 'tokens' => ( is => 'rw' );

has 'state'	    => ( is => 'rw' );
has 'tmp_token' => ( is => 'rw' );
has 'tmp_style_context' => ( is => 'rw' );
has 'tmp_link_context'  => ( is => 'rw' );
has 'tmp_image_context' => ( is => 'rw' );

has 'pointer'	=> ( is => 'rw' );

my $SYM_STRONG		= '*';
my $SYM_UNDERLINE	= '_';
my $SYM_EMPHASIS	= '/';
my $SYM_QUOTE		= '"';

my $SYM_GROUP_STYLE_RE = qr/^(\*|_|\/|")$/o;

my $SYM_LINK_START  = '[';
my $SYM_LINK_END    = ']';

my $SYM_IMAGE_START	= '{';
my $SYM_IMAGE_END	= '}';

my $SYM_HEADER 		= '#';

my $RE_DIGIT	= qr/^\d$/;

sub tokenize {
	my ($self, $pml) = @_;
	#INFO '-------------------------------------------';
	##INFO "Start new tokenize";
	$self->pml($pml || $self->fatal("Must supply 'pml' to tokenize"));
	$self->chars([split//,$pml]);
	$self->state('data');
	$self->tokens([]);
	$self->tmp_token(undef);

	$self->_tokenize;
	return $self;
}

# ------------------------------------------------------------------------------

sub get_next_token {
	my ($self) = @_;
	return shift(@{$self->tokens||[]}) || 0;
}

# ------------------------------------------------------------------------------

# Assumptions
#
# * Nesting:
# 	- a paragraph CANNOT nest inside another paragraph
#	- images only in strings
# * Data ends with 0 (opened blocks aren't closed - responsibility of tag parser)
# * No tag balancing. Doesn't check whether start tag tokens have matching ends. That's
#	up to the token parser.
#
sub _tokenize {
	my ($self) = @_;

	$self->pointer(-1);
	my $total_chars = $#{$self->chars};

	while($self->pointer < $total_chars) {
	#while(@{$self->chars}) {
		#my $char = shift @{$self->chars};
		my $char = $self->chars->[$self->pointer($self->pointer+1)];

		my $state = $self->state;

		#DEBUG "[[State:$state]]";
		#DEBUG "  > Read char '$char'";

		# --------------

		if ($state eq 'string') {
			
			if ($char eq $SYM_HEADER) {
				# Hit a potential header. Move to p_header and read next char.
				$self->_move_to('p_header');
				next;
			}

			if ($char eq $SYM_IMAGE_START) {
				# Hit potential image. Move to p_image and read next char.
				$self->_move_to('p_image');
				next;
			}

			if ($char =~ $SYM_GROUP_STYLE_RE) {
				# Hit a potential starting style token. Move
				# to p_style state and read the next char.
				$self->tmp_style_context($1);
				#TRACE "  > Store tmp style context [$1]";
				$self->_move_to('p_style');
				next;
			}

			if ($char eq $SYM_LINK_START) {
				# Potential href link. Move to p_link state
				# and read the next char.
				$self->_move_to('p_link');
				next;
			}

			# Plain char, append to current string
			# token and stay in string state.
			#TRACE '  > Append to open token';
			$self->_append_char_to_tmp_string_token( $char );
			next;
		}

		# --------------

		if ($state eq 'p_header') {

			if ($char eq $SYM_HEADER) {
				# Complete potential header sequence so create new HEADER
				# token and move to header_level state
				$self->_create_token({type=>'HEADER',level=>'',text=>''});
				$self->_move_to('header_level');
				next;
			}

			# Didn't complete header sequence.
			# Requeue the header char and the char we just read.			
			if ($self->_is_tmp_string_token_open) {
				#TRACE "  > Plain header char (uncompleted sequence)";
				$self->_requeue( $SYM_HEADER );				
				$self->_requeue( $char );
				$self->_move_to('data');
				next;
			}
		}

		# --------------

		if ($state eq 'header_level') {

			if ($char eq '|') {
				# Finished header level so output level and switch to
				# header text and read next char.				
				#TRACE "  --> Read header switch";
				$self->_move_to('header_text');
				next;
			}

			if ($char !~ $RE_DIGIT) {
				$self->fatal("unexpected char ($char) in header level");
			}

			# Otherwise append to header level
			#TRACE "  --> Add '$char' to current header level";
			$self->tmp_token->{level} .= $char;
			next;
		}

 		# --------------

 		if ($state eq 'header_text') {

 			if ($char eq $SYM_HEADER) {
 				# Potentially reached the end of the header. Move to p_e_header
 				$self->_move_to('p_e_header');
 				next;
 			}

 			# Otherwise append to header text
 			$self->tmp_token->{text} .= $char;
 			next;
 		}

 		# --------------

 		if ($state eq 'p_e_header') {

 			if ($char eq $SYM_HEADER) {
 				# Completed header end sequence. Emit header token
 				# and move to data state.
 				$self->_emit_token;
 				$self->_move_to('data');
 				next; 				
 			}

 			# Otherwise, didn't complete sequence. Append the header char to
 			# the header_text currently open and requeue the next char.
 			$self->tmp_token->{text} .= $SYM_HEADER;
 			$self->requeue( $char );
 		}

 		# --------------

		if ($state eq 'start_string') {
			# Attempt to start a string.
			# If a control char then move to appropriate state.
			if ($char eq $SYM_LINK_START) {
				$self->_move_to('p_link');
				next;
			}

			# If potential link start then move to p_link
			if ($char eq $SYM_LINK_START) {
				$self->_move_to('p_link');
				next;
			}

			# Starting a new string. If the char is a plain char we start a			
			# new STRING token and move to string mode.
			$self->_create_token({ type=>'STRING', content=>$char });
			$self->_move_to('string');
			next;
		}

		# --------------

		if ($state eq 'p_style') {

			if ($char =~ $SYM_GROUP_STYLE_RE) {
				# In potential style state and got another style char. If it
				# matches the current tmp style context then output style
				# token and move to string state.
				if ($1 eq $self->tmp_style_context) {
					
					# If an open token exists then emit it.
					$self->_emit_token;


					if ($self->_is_tmp_string_token_open) {
						#TRACE "  > Matched style context (".$self->tmp_style_context.')';
						$self->_emit_token;
					}

					$self->_emit_token({type=>'STRONG'}) 	if $1 eq $SYM_STRONG;
					$self->_emit_token({type=>'UNDERLINE'}) if $1 eq $SYM_UNDERLINE;
					$self->_emit_token({type=>'EMPHASIS'}) 	if $1 eq $SYM_EMPHASIS;
					$self->_emit_token({type=>'QUOTE'}) 	if $1 eq $SYM_QUOTE;

					$self->_move_to('start_string');
					$self->tmp_style_context(undef);					
				}
			}

			# Was potential style but didn't complete the sequence.
			# If there's an open string token then append the style char to it,
			# requeue the next char, and move back to string state.
			if ($self->_is_tmp_string_token_open) {
				#TRACE "  > Plain style char (uncompleted sequence)";
				$self->_append_char_to_tmp_string_token( $self->tmp_style_context );
				$self->_requeue( $char );
				$self->_move_to('string');
				next;
			}

			$self->tmp_style_context(undef);
			next;
		}

		# --------------

		if ($state eq 'p_link') {

			# Potential link. If complete link start sequence then
			# move to link_href state, creating a new LINK token.
			if ($char eq $SYM_LINK_START) {

				$self->_emit_token;

				$self->_create_token({type=>'LINK',href=>'',text=>''});
				$self->_move_to('link_href');
				$self->tmp_link_context('href');				
				next;
			}

			# Didn't complete sequence.
			# If there's an open string token then append the link char to it,
			# requeue the next char, and move back to string state.
			if ($self->_is_tmp_string_token_open) {
				#TRACE "  > Plain link char (uncompleted sequence)";
				$self->_append_char_to_tmp_string_token( $char );
				
			}
			# Didn't complete sequence.
			# No open string so start a new string and append style char to it.
			# Requeue next char.
			else  {
				#TRACE "  > Plain style char (uncompleted sequence)";
				$self->_create_token({type=>'STRING',content=>$self->tmp_style_context});				
			}
			$self->_requeue( $char );
			$self->_move_to('string');
			next;
		}

		# --------------

		if ($state eq 'p_image') {
			# Potential image. If complete sequence then move to image_src state
			# creating new IMAGE token.
			if ($char eq $SYM_IMAGE_START) {
				$self->_emit_token;
				$self->_create_token({type=>'IMAGE',src=>'',width=>'',height=>'',align=>''});
				$self->tmp_image_context('src');
				$self->_move_to('image_src');
				next;
			}

			# Didn't complete sequence.
			# If there's an open string token then appen the image char to it,
			# requeue the next char, and move to data state.
			if ($self->_is_tmp_string_token_open) {
				#TRACE "  > Plain image char (uncompleted sequence)";
				$self->_append_char_to_tmp_string_token( $SYM_IMAGE_START );
			}
			# Didn't complete sequence.
			# No open string so start a new string and append char to it.
			# Requeue next char.
			else {
				#TRACE "  > Plain image char (uncompleted sequence)";
				$self->_create_token({type=>'STRING',content=>$SYM_IMAGE_START});	
			}
			$self->_requeue( $char );
			$self->_move_to('data');
			next;
		}

		# --------------

		if ($state eq 'image_src') {

			# Potential end of image data
			if ($char eq $SYM_IMAGE_END) {
				$self->_move_to('p_e_image');
				next;
			}

			# Src/Options delimiter
			if ($char eq '|') {
				$self->tmp_image_context('options');
				$self->_move_to('image_options');
				next;
			}

			# Append to current image src
			$self->tmp_token->{src} .= $char;
			next;
		}

		# --------------

		if ($state eq 'image_options') {
			# Potential end of image data
			if ($char eq $SYM_IMAGE_END) { $self->_move_to('p_e_image'); next }

			if ($char eq 'H') { $self->_move_to('image_options_height'); 	   next }
			if ($char eq 'W') { $self->_move_to('image_options_width');  	   next }
			if ($char eq '<') { $self->_move_to('p_image_align_left_span');    next }
			if ($char eq '>') { $self->_move_to('p_image_align_right_center'); next }

			next; # Skip anything else
		}

		# --------------

		if ($state eq 'p_image_align_left_span') {
			# Complete sequences
			if ($char eq '<') {
				$self->tmp_token->{align} = 'left';
				$self->_move_to('image_options');
				next;
			}
			if ($char eq '>') {
				$self->tmp_token->{align} = 'span';
				$self->_move_to('image_options');
				next;
			}
			# Otherwise unexpected so error
			$self->fatal("bad image alignment sequence");
		}

		# --------------

		if ($state eq 'p_image_align_right_center') {
			# Complete sequences
			if ($char eq '<') {
				$self->tmp_token->{align} = 'center';
				$self->_move_to('image_options');
				next;
			}
			if ($char eq '>') {
				$self->tmp_token->{align} = 'right';
				$self->_move_to('image_options');
				next;
			}
			# Otherwise unexpected so error
			$self->fatal("bad image alignment sequence");
		}

		# --------------

		if ($state eq 'image_options_height') {
			if ($char =~ $RE_DIGIT) { $self->tmp_token->{height} .= $char; next }
			if ($char eq ',')  { $self->_move_to('image_options'); 	  next }
			if ($char eq '}')  {
				$self->_move_to('image_options');
				$self->_requeue( $char );
				next;
			}
			$self->fatal("image height option expecting digit");
		}

		# --------------

		if ($state eq 'image_options_width') {
			if ($char =~ $RE_DIGIT) { $self->tmp_token->{width} .= $char; next }
			if ($char eq ',')  { $self->_move_to('image_options');   next }
			if ($char eq '}')  {
				$self->_move_to('image_options');
				$self->_requeue( $char );
				next;
			}
			$self->fatal("image width option expecting digit");
		}

		# --------------

		if ($state eq 'p_e_image') {
			
			# Complete sequence so emit IMAGE token and move to data state
			if ($char eq $SYM_IMAGE_END) {
				$self->_emit_token;
				$self->tmp_image_context(undef);
				$self->_move_to('data');
				next;
			}
			# Didn't complete sequence. If in options context then error
			# as not allowed here, otherwise append to current src.
			if ($self->tmp_image_context eq 'options') {
				$self->fatal("not allowed plain $SYM_IMAGE_END symbol in image options");
			}
			$self->tmp_token->{src} .= $SYM_IMAGE_END;
			$self->_requeue( $char );
			next;
		}

		# --------------

		if ($state eq 'link_href' || $state eq 'link_text') {

			# Potential end link. Move to p_e_link state and read next char.
			if ($char eq $SYM_LINK_END) { $self->_move_to('p_e_link'); next }

			# Switch context from href to text and get next char
			if ($char eq '|') { $self->tmp_link_context('text'); next }

			if ($state eq 'link_href') { $self->tmp_token->{href} .= $char; next }
			if ($state eq 'link_text') { $self->tmp_token->{text} .= $char; next }			

			$self->fatal("unexpected char reading $state");			
		}

		# --------------

		if ($state eq 'p_e_link') {

			# If complete end sequence then emit the link token
			# and move back to string state.
			if ($char eq $SYM_LINK_END) {
				#TRACE "  > Complete link end sequence";
				$self->_move_to('start_string');
				$self->_emit_token;		
				next;		
			}

			# Uncomplete sequence, treat as continuation
			# of href or text.
			if ($self->tmp_link_context eq 'href') {
				$self->tmp_token->{href} .= $char;
				$self->state('link_href');
			}
			if ($self->tmp_link_context eq 'text') {
				$self->tmp_token->{text} .= $char;
				$self->state('link_text');
			}
			next;

		}

		# --------------

		if ($state eq 'data') {
			
			if ($char eq $SYM_HEADER) {
				# Hit a potential header. Move to p_header and read next char.
				$self->_move_to('p_header');
				next;
			}

			if ($char eq $SYM_IMAGE_START) {
				# Hit potential image. Move to p_image and read next char.
				$self->_move_to('p_image');
				next;
			}

			if ($char =~ $SYM_GROUP_STYLE_RE) {
				# Hit a potential style token. Move to p_style and read the next char.
				$self->tmp_style_context($1);
				#TRACE "  > Store tmp style context [$1]";
				$self->_move_to('p_style');	
				$self->_create_token({type=>'PARA'});
				next;		
			}

			# Read a plain char and in open data mode.
			# If not a space move to string state push the char back to the
			# queue and output a paragraph start token.
			if ($char ne ' ') {
				$self->_move_to('start_string');
				$self->_requeue( $char );
				$self->_create_token({type=>'PARA'});
			}
			next;
		}
	}

	# If there are any tokens currently pending, then emit them now.
	if ($self->tmp_token) {
		#TRACE "[[Output tailing token]]";
		if ($self->tmp_token->{type} eq 'STRING') {
			#INFO "CONTENT IS ".$self->tmp_token->{content};
			$self->_emit_token if $self->tmp_token->{content} ne '';
		}
		else {
			$self->_emit_token;
		}
	}
	
	#DEBUG "[[Tokenization complete]]";
	return;
}

# ------------------------------------------------------------------------------

sub fatal {
	my ($self, @msg) = @_;
	my $msg = join '',@msg;
	#ERROR "!!Tokenizer Error: $msg!!";
	die "$msg\n\n";
}

# ------------------------------------------------------------------------------

sub _create_token {
	my ($self, $hash) = @_;

	#DEBUG "  > Create token";

	# If there's a current "pending" token then emit it before creating
	# the new token in tmp space.
	if ($self->tmp_token) {
		$self->_emit_token($self->tmp_token);
	}

	#TRACE "  > Creating new token '$$hash{type}'";
	
	$self->tmp_token( $hash );
	return;
}

# ------------------------------------------------------------------------------

# Emit the current tmp_token to the token array
# If hash supplied will create and emit that token, otherwise will attempt
# to output tmp_token.
sub _emit_token {
	my ($self, $optional_new_token_hash) = @_;

	my $token = $optional_new_token_hash
				? $optional_new_token_hash
				: $self->tmp_token;
	
	return unless $token; # Bounce out if nothing to do

	my $content='';
	if ($token->{type} eq 'STRING') {
		$content=$token->{content};
		if (!$content) {
			return; # Discard if string token but no content
		}
	}

	#TRACE "  > Emit token '$token->{type}' [$content]";
	$self->tmp_token(undef);
	push @{$self->tokens}, $token;
	return;
}

# ------------------------------------------------------------------------------

sub _read_and_clear_tmp_token {
	my ($self) = @_;
	my $token = $self->tmp_token;
	$self->fatal("Can't read and clear tmp token - no current tmp token") if !$token;
	$self->tmp_token(undef);
	return $token;
}

# ------------------------------------------------------------------------------

sub _requeue {
	my ($self,$char_to_requeue) = @_;
	$self->pointer( $self->pointer - 1 );
	#unshift @{$self->chars}, $char_to_requeue;
	#TRACE "  > Requeue [$char_to_requeue]";
}

# ------------------------------------------------------------------------------

sub _move_to {
	my ($self,$state_to_move_to) = @_;
	$self->state($state_to_move_to);
	#TRACE "  > Move to state [$state_to_move_to]";
}

# ------------------------------------------------------------------------------

sub _append_char_to_tmp_string_token {
	my ($self, $char_to_append) = @_;

	$self->fatal("unable to append null char to tmp string token") unless $char_to_append;

	#TRACE "  > Appending char [$char_to_append] to tmp string token";
	if (!$self->tmp_token) {
		$self->fatal("Can't append to uninitialised string token!");
	}
	$self->tmp_token->{content} .= $char_to_append;
}

# ------------------------------------------------------------------------------

sub _is_tmp_string_token_open {	
	return $_[0]->tmp_token
	    && $_[0]->tmp_token->{type} eq 'STRING'
	    && $_[0]->tmp_token->{content};
}

# ------------------------------------------------------------------------------


1;
