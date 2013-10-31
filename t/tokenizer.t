use strict;
use warnings;
use boolean;

use Test::More;

use_ok "PML::Tokenizer";

my $pml =<<EOT
##Heading 1##
###Heading 2###
####Heading 3####

This is a paragraph.
Same paragraph.

New paragraph with **bold** text and __underlined__ text and
//italic// text.

This *isn't* bold

Not a #heading and neither is #this#
EOT
;


my $tokenizer = new_ok "PML::Tokenizer", [ pml => $pml ];

while(my $token = $tokenizer->get_next_token) {
	print $token->content;
}
print"\n";


	test__get_next_token( $tokenizer );





done_testing();
exit(0);


sub test__get_next_token {
	my ($tokenizer) = @_;

	subtest "Test method get_next_token" => sub {

		$tokenizer->tokens([]);

		push @{$tokenizer->tokens}, PML::Tokenizer::Token->new( type=>'CHAR', content => 'abc');
		push @{$tokenizer->tokens}, PML::Tokenizer::Token->new( type=>'CHAR', content => 'bcd');
		push @{$tokenizer->tokens}, PML::Tokenizer::Token->new( type=>'CHAR', content => 'cde');

		is($tokenizer->get_next_token->content, 'abc', "Got token");
		is($tokenizer->get_next_token->content, 'bcd', "Got token");
		is($tokenizer->get_next_token->content, 'cde', "Got token");
		is($tokenizer->get_next_token, 0, "No token");

		# Tokens should now be empty
		is(scalar @{$tokenizer->tokens}, 0, "All tokens read");
	};
	return;
}