use strict;
use warnings;
use boolean;

use Test::More;
use Test::Exception;

use_ok "PML::Tokenizer";


	test__get_next_token();

	test__plain_chars();
	test__emphasis();
	test__strong();
	test__underline();
	test__header_end_of_data();

	test_util__is_head_block_open();

	#test_newline(); # Test: newline after char, after other tag


done_testing();
exit(0);

# ------------------------------------------------------------------------------

sub _match_tokens {
	my ($tokenizer,$expected_ar,$name) = @_;
	$name||='';

	my $token = $tokenizer->get_next_token;
	my @generated;
	while($token != 0) {
		push @generated, $token->type;
		$token = $tokenizer->get_next_token;
	}

	my $ok = is_deeply(\@generated, $expected_ar, "Tokens as expected ($name)");
	unless ($ok) {		
		diag("Expected: ",join(",",@$expected_ar));
		diag("Got:      ",join(",",@generated));
	}
}

# ------------------------------------------------------------------------------

sub test__header_end_of_data {
	subtest "Test '## == header'" => sub {
				
		my $t;

		$t = PML::Tokenizer->new( pml => '#head#');
		_match_tokens($t,[qw|S_BLOCK CHAR CHAR CHAR CHAR CHAR CHAR E_BLOCK|],'Not header');

		$t = PML::Tokenizer->new( pml => '##head##');
		_match_tokens($t,[qw|S_HEAD1 CHAR CHAR CHAR CHAR E_HEAD1|],'Header1');		

		$t = PML::Tokenizer->new( pml => '###head###');
		_match_tokens($t,[qw|S_HEAD2 CHAR CHAR CHAR CHAR E_HEAD2|],'Header2');

		$t = PML::Tokenizer->new( pml => '####head####');
		_match_tokens($t,[qw|S_HEAD3 CHAR CHAR CHAR CHAR E_HEAD3|],'Header3');

		$t = PML::Tokenizer->new( pml => '#####head#####');
		_match_tokens($t,[qw|S_HEAD4 CHAR CHAR CHAR CHAR E_HEAD4|],'Header4');

		$t = PML::Tokenizer->new( pml => '######head######');
		_match_tokens($t,[qw|S_HEAD5 CHAR CHAR CHAR CHAR E_HEAD5|],'Header5');

		$t = PML::Tokenizer->new( pml => '#######head#######');
		_match_tokens($t,[qw|S_HEAD6 CHAR CHAR CHAR CHAR E_HEAD6|],'Header6');

		# TODO Error on mismatched tags		
		#$t = PML::Tokenizer->new( pml => '#######head######');
		#_match_tokens($t,[qw|S_BLOCK S_HEAD6 CHAR CHAR CHAR CHAR S_HEAD5 E_BLOCK|],'Mismatched tags');
		
		dies_ok { $t = PML::Tokenizer->new( pml => '########head########') }
				'Die on invalid header string';

	}; return
}

# ------------------------------------------------------------------------------

sub test__plain_chars {
	subtest "Test 'plain chars'" => sub {
				
		my $t = PML::Tokenizer->new( pml => 'abc');
		_match_tokens($t, [qw|S_BLOCK CHAR CHAR CHAR E_BLOCK|]);

	}; return
}

# ------------------------------------------------------------------------------

sub test__emphasis {
	subtest "Test '// == emphasis'" => sub {
				
		my $t = PML::Tokenizer->new( pml => '//abc//');
		_match_tokens($t, [qw|S_BLOCK S_EMPHASIS CHAR CHAR CHAR E_EMPHASIS E_BLOCK|]);

	}; return
}

# ------------------------------------------------------------------------------

sub test__strong {
	subtest "Test '** == strong'" => sub {
				
		my $t = PML::Tokenizer->new( pml => '**abc**');
		_match_tokens($t, [qw|S_BLOCK S_STRONG CHAR CHAR CHAR E_STRONG E_BLOCK|]);

	}; return
}

# ------------------------------------------------------------------------------

sub test__underline {
	subtest "Test '__ == underline'" => sub {
				
		my $t = PML::Tokenizer->new( pml => '__abc__');
		_match_tokens($t, [qw|S_BLOCK S_UNDERLINE CHAR CHAR CHAR E_UNDERLINE E_BLOCK|]);

	}; return
}

# ------------------------------------------------------------------------------

sub test__get_next_token {	
	subtest "Test method get_next_token" => sub {

		my $tokenizer = PML::Tokenizer->new( pml => '');
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
	}; return;
}

# ------------------------------------------------------------------------------

sub test_util__is_head_block_open {
	subtest "Test utility _is_head_block_open" => sub {

		my $tokenizer = PML::Tokenizer->new( pml => '');

		$tokenizer->matching_context({});
		$tokenizer->matching_context->{HEAD1} = 1;
		is ($tokenizer->_is_head_block_open, 1, "HEAD1 = true");

		$tokenizer->matching_context({});
		$tokenizer->matching_context->{HEAD1} = 1;
		$tokenizer->matching_context->{HEAD3} = 1;
		is ($tokenizer->_is_head_block_open, 1, "HEAD1 + HEAD3 = true");

	}; return;
}