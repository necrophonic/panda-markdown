use strict;
use warnings;
use boolean;

use Test::More;
use Test::Exception;

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


	test__emphasis();
	test__strong();
	test__underline();
	test__header();


done_testing();
exit(0);

# ------------------------------------------------------------------------------

sub test__header {
	subtest "Test '## == header'" => sub {
				
		my $t;

		$t = PML::Tokenizer->new( pml => '#head#');
		is( $t->get_next_token->content . $t->get_next_token->content, '#h', '#h' );

		$t = PML::Tokenizer->new( pml => '##head##');
		is( $t->get_next_token->content, '[[H1]]', 'HEAD1' );
		
		$t = PML::Tokenizer->new( pml => '###head###');
		is( $t->get_next_token->content, '[[H2]]', 'HEAD2' );

		$t = PML::Tokenizer->new( pml => '####head####');
		is( $t->get_next_token->content, '[[H3]]', 'HEAD3' );

		$t = PML::Tokenizer->new( pml => '#####head#####');
		is( $t->get_next_token->content, '[[H4]]', 'HEAD4' );

		$t = PML::Tokenizer->new( pml => '######head######');
		is( $t->get_next_token->content, '[[H5]]', 'HEAD5' );

		$t = PML::Tokenizer->new( pml => '#######head#######');
		is( $t->get_next_token->content, '[[H6]]', 'HEAD6' );

		dies_ok { $t = PML::Tokenizer->new( pml => '########head########') }
				'Die on invalid header string';

	}; return
}

# ------------------------------------------------------------------------------

sub test__emphasis {
	subtest "Test '// == emphasis'" => sub {
				
		my $t = PML::Tokenizer->new( pml => '//abc//');

		is( $t->get_next_token->content, '[[EMPH]]', 'Start with EMPH tag' );
		is( $t->get_next_token->content, 'a',		 'Char tag [a]'		   );
		is( $t->get_next_token->content, 'b',		 'Char tag [b]'		   );
		is( $t->get_next_token->content, 'c',		 'Char tag [c]'		   );
		is( $t->get_next_token->content, '[[EMPH]]', 'End with EMPH tag'   );
		is( $t->get_next_token, 		 0, 		 'Finish tokens'   	   );

	}; return
}

# ------------------------------------------------------------------------------

sub test__strong {
	subtest "Test '** == strong'" => sub {
				
		my $t = PML::Tokenizer->new( pml => '**abc**');

		is( $t->get_next_token->content, '[[STRONG]]', 'Start with STRONG tag' );
		is( $t->get_next_token->content, 'a',		   'Char tag [a]'		   );
		is( $t->get_next_token->content, 'b',		   'Char tag [b]'		   );
		is( $t->get_next_token->content, 'c',		   'Char tag [c]'		   );
		is( $t->get_next_token->content, '[[STRONG]]', 'End with STRONG tag'   );
		is( $t->get_next_token, 		 0, 		   'Finish tokens'   	   );

	}; return
}

# ------------------------------------------------------------------------------

sub test__underline {
	subtest "Test '__ == underline'" => sub {
				
		my $t = PML::Tokenizer->new( pml => '__abc__');

		is( $t->get_next_token->content, '[[UNDER]]', 'Start with UNDER tag' );
		is( $t->get_next_token->content, 'a',		   'Char tag [a]'		   );
		is( $t->get_next_token->content, 'b',		   'Char tag [b]'		   );
		is( $t->get_next_token->content, 'c',		   'Char tag [c]'		   );
		is( $t->get_next_token->content, '[[UNDER]]', 'End with UNDER tag'   );
		is( $t->get_next_token, 		 0, 		   'Finish tokens'   	   );

	}; return
}

# ------------------------------------------------------------------------------

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
	}; return;
}

# ------------------------------------------------------------------------------
