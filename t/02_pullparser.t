#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;

use Test::More;
use Test::Exception;

package Test {
	use Moo;
	use Log::Declare;
	extends 'Text::CaffeinatedMarkup::PullParser';
	has tokens => (is=>'rw',default=>sub{[]});

	my $all = sub {
		my ($self) = @_;
		push @{$self->tokens}, $self->token;		
		$self->_set_token(undef);
	};


	sub handle_text 		  {$all->($_[0])};
	sub handle_emphasis 	  {$all->($_[0])};
	sub handle_link 		  {$all->($_[0])};
	sub handle_image 		  {$all->($_[0])};
	sub handle_divider 		  {$all->($_[0])};
	sub handle_header 		  {$all->($_[0])};
	sub handle_linebreak      {$all->($_[0])};
	sub handle_paragraphbreak {$all->($_[0])};

	
};

package main;


plan tests => 13;

	use_ok 'Text::CaffeinatedMarkup::PullParser';
	can_ok 'Text::CaffeinatedMarkup::PullParser', qw|tokenize|;	
	
	subtest 'Peek' => sub {
		dies_ok {
			my $pp = Text::CaffeinatedMarkup::PullParser->new(cml=>'');
			$pp->_set_chars([split//,'abc']);
			$pp->_set_pointer(2); # Set onto 'c'
			$pp->_peek;
		} 'dies when over peeking';

		lives_ok {
			my $pp = Text::CaffeinatedMarkup::PullParser->new(cml=>'');
			$pp->_set_chars([split//,'abc']);
			$pp->_set_pointer(1); # Set onto 'c'
			is $pp->_peek, 'c', 'peek at "c"';
		} 'live ok';
	};


	subtest 'Parse #1' => sub {
		plan tests => 5;
		my $cml = 'The **cat** sat __on__ the //mat//';
		my $pp  = Test->new( );
		$pp->tokenize($cml);

		test_expected_tokens_list(
			$pp->tokens,
			[qw|text emphasis text emphasis text emphasis text emphasis text emphasis text emphasis|]
		);

		# Check the content of some tokens
		is $pp->tokens->[0]->content, 'The ';
		is $pp->tokens->[1]->type, 'strong';
		is $pp->tokens->[5]->type, 'underline';
		is $pp->tokens->[9]->type, 'emphasis';
	};

	subtest 'Parse #2' => sub {
		plan tests => 4;

		my $cml = '**Yay!**';
		my $pp  = Test->new( );
		$pp->tokenize($cml);

		test_expected_tokens_list(
			$pp->tokens,
			[qw|emphasis text emphasis|]
		);
		is $pp->tokens->[1]->content, 'Yay!';
		is $pp->tokens->[0]->type, 'strong';
		is $pp->tokens->[2]->type, 'strong';

	};

	subtest 'Parse #3' => sub {
		plan tests => 3;

		my $cml = 'Go here: [[http://www.example.com|example site]]';
		my $pp  = Test->new( );
		$pp->tokenize($cml);

		test_expected_tokens_list(
			$pp->tokens,
			[qw|text link|]
		);
		my $token = $pp->tokens->[1];
		is $token->href, 'http://www.example.com', 'href is correct';
		is $token->text, 'example site', 'text is correct';
	};

	subtest 'Parse #4' => sub {
		plan tests => 3;

		my $cml = 'Go here: [[http://www.example.com]]';
		my $pp  = Test->new( );
		$pp->tokenize($cml);

		test_expected_tokens_list(
			$pp->tokens,
			[qw|text link|]
		);
		my $token = $pp->tokens->[1];
		is $token->href, 'http://www.example.com', 'href is correct';
		is $token->text, '', 'text is correct';
	};

	subtest 'Parse #5' => sub {
		plan tests => 3;

		my $cml = '{{images/cat.jpg|>>,W100,H50}}';
		my $pp  = Test->new( );
		$pp->tokenize($cml);

		test_expected_tokens_list(
			$pp->tokens,
			[qw|image|]
		);
		my $token = $pp->tokens->[0];
		is $token->src, 'images/cat.jpg', 'src is correct';
		is $token->options, '>>,W100,H50', 'options is correct';
	};

	subtest 'Parse #6' => sub {
		plan tests => 3;

		my $cml = '{{images/cat.jpg}}';
		my $pp  = Test->new( );
		$pp->tokenize($cml);

		test_expected_tokens_list( $pp->tokens, [qw|image|] );

		my $token = $pp->tokens->[0];
		is $token->src, 'images/cat.jpg', 'src is correct';
		is $token->options, '', 'options is correct';
	};

	subtest 'Parse #7' => sub {
		plan tests => 1;

		my $cml = "~~ABC\n";
		my $pp  = Test->new( );
		$pp->tokenize($cml);

		test_expected_tokens_list( $pp->tokens, [qw|divider|] );
	};

	subtest 'Parse #8' => sub {
		plan tests => 3;

		my $cml = '\**cat \***dog**';
		my $pp  = Test->new( );
		$pp->tokenize($cml);

		test_expected_tokens_list( $pp->tokens, [qw|text emphasis text emphasis|] );

		is $pp->tokens->[0]->content, '**cat *', 'content is correct';
		is $pp->tokens->[2]->content, 'dog',    'content is correct';
	};

	subtest 'Parse #9' => sub {
		plan tests => 4;

		my $cml_1 = '# Header';
		my $pp  = Test->new();
		$pp->tokenize($cml_1);
		test_expected_tokens_list( $pp->tokens, [qw|header|] );
		is $pp->tokens->[0]->level, 1, 'level is correct (1)';		

		my $cml_2 = '### Header';		
		$pp  = Test->new();
		$pp->tokenize($cml_2);
		test_expected_tokens_list( $pp->tokens, [qw|header|] );
		is $pp->tokens->[0]->level, 3, 'level is correct (3)';
	};

	subtest 'Parse #10 - breaks' => sub {
		plan tests => 5;

		my $cml_1 = "Text\nText after";
		my $pp    = Test->new();
		$pp->tokenize($cml_1);
		test_expected_tokens_list( $pp->tokens, [qw|text line_break text|] );
		is $pp->tokens->[2]->content, 'Text after', 'text ok';

		my $cml_2 = "Text\n\nText after";
		my $pp    = Test->new();
		$pp->tokenize($cml_2);
		test_expected_tokens_list( $pp->tokens, [qw|text paragraph_break text|] );

		my $cml_3 = "Text\n\n\n\n\nMore Text after";
		my $pp    = Test->new();
		$pp->tokenize($cml_3);
		test_expected_tokens_list( $pp->tokens, [qw|text paragraph_break text|] );
		is $pp->tokens->[2]->content, 'More Text after', 'text ok';
	};



done_testing;

# -----------------------------------------------------------------------------

# Test the classes of returned tokens - doesn't test
# the content of any of the tokens.
sub test_expected_tokens_list {
	my ($tokens_got, $tokens_expected) = @_;

	subtest 'expect tokens' => sub {
		plan tests => scalar @$tokens_expected;

		for (my $i=0;$i<@$tokens_expected;$i++)	{

			my $camel_token = ucfirst $tokens_expected->[$i];
			   $camel_token =~ s/_(\w)/\u$1/g;

			my $expected_class = 'Text::CaffeinatedMarkup::PullParser::'.$camel_token.'Token';
			is ref $tokens_got->[$i], $expected_class, ref($tokens_got->[$i]) ." == $expected_class";
		}
	};
}

# -----------------------------------------------------------------------------
