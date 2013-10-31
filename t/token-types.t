use strict;
use warnings;

use Test::More;
use Test::Exception;
use PML::Tokenizer::Token;

note("Test valid types");
for (qw|
		TEXT
		S_BOLD E_BOLD
		S_EMPH E_EMPH
		S_UNDR E_UNDR
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
