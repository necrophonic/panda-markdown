use strict;
use warnings;

use Test::More;
use Test::Exception;
use PML::Tokenizer::Token;

note("Test valid types");
for (qw|
		CHAR
		S_STRONG	E_STRONG	
		S_EMPHASIS	E_EMPHASIS
		S_UNDERLINE E_UNDERLINE
		S_QUOTE		E_QUOTE
		S_HEAD1 S_HEAD2 S_HEAD3 S_HEAD4 S_HEAD5 S_HEAD6
		E_HEAD1 E_HEAD2 E_HEAD3 E_HEAD4 E_HEAD5 E_HEAD6
		S_BLOCK E_BLOCK
	|) {
	lives_ok { PML::Tokenizer::Token->new( type => $_ ) } "Type [$_] is valid";
}


note("Test invalid types");
for (qw|
		CAT GOAT AARDVARK s_bold
	|) {
	dies_ok { PML::Tokenizer::Token->new( type => $_ ) } "Type [$_] is not valid";
}


note("Test mandatory args");
dies_ok { PML::Tokenizer::Token->new() } "Dies with no args";

done_testing();
exit(0);
