use strict;
use warnings;

use Test::More;

use_ok "PML::Tokenizer";

my $tokenizer = new_ok "PML::Tokenizer", [ pml => 'abc' ];


	test__get_next_token( $tokenizer );


done_testing();
exit(0);


sub test__get_next_token {
	my ($tokenizer) = @_;

	subtest "Test method get_next_token" => sub {

		$tokenizer->tokens([]);

		push @{$tokenizer->tokens}, PML::Tokenizer::Token->new( type=>'TEXT', content => 'abc');
		push @{$tokenizer->tokens}, PML::Tokenizer::Token->new( type=>'TEXT', content => 'bcd');
		push @{$tokenizer->tokens}, PML::Tokenizer::Token->new( type=>'TEXT', content => 'cde');

		is($tokenizer->get_next_token->content, 'abc', "Got token");
		is($tokenizer->get_next_token->content, 'bcd', "Got token");
		is($tokenizer->get_next_token->content, 'cde', "Got token");
		is($tokenizer->get_next_token, 0, "No token");

		# Tokens should now be empty
		is(scalar @{$tokenizer->tokens}, 0, "All tokens read");
	};
	return;
}