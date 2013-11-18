#!/usr/bin/env perl
use strict;
use Test::More;
use Test::Exception;

use_ok 'PML::Tokenizer';

{
	my $tokenizer = new_ok 'PML::Tokenizer';

	dies_ok  {$tokenizer->tokenize} 	  'tokenize() dies with no pml supplied (1)';
	dies_ok  {$tokenizer->tokenize('')}   'tokenize() dies with no pml supplied (2)';
	lives_ok {$tokenizer->tokenize('ab')} 'tokenize() lives with pml supplied';
}

# ------------------------------------------------------------------------------

subtest "End of data" => sub {
	my $tokenizer = PML::Tokenizer->new;
	is($tokenizer->get_next_token,0,"Zero returned at end of tokens");
};

# ------------------------------------------------------------------------------

subtest "Plain text paragraph" => sub {
	my $tokenizer = PML::Tokenizer->new;	
	$tokenizer->tokenize( 'Text' );
	is(_read_all_tokens($tokenizer)
	   ,'STRING'
	   ,'Correct tokenization');
};

# ------------------------------------------------------------------------------

subtest "Basic style markup in paragraph" => sub {

	my $tokenizer = PML::Tokenizer->new;	
	$tokenizer->tokenize( 'Text with **strong**, __underline__ and //emphasis//' );
	is(_read_all_tokens($tokenizer)
		,'STRING,STRONG,STRING,STRONG,STRING,UNDERLINE,STRING,UNDERLINE,STRING,EMPHASIS,STRING,EMPHASIS'
		,'Correct tokenization');


	subtest "Strong" => sub {		
		$tokenizer->tokenize( '**Start with strong**' );
		is(_read_all_tokens($tokenizer)
		   ,'STRONG,STRING,STRONG'
		   ,'Correct tokenization - start with strong');

		$tokenizer->tokenize( 'String **End with strong**' );
		is(_read_all_tokens($tokenizer)
		   ,'STRING,STRONG,STRING,STRONG'
		   ,'Correct tokenization - end with strong');
	};

	subtest "Emphasis" => sub {
		$tokenizer->tokenize( '//Start with emphasis//' );
		is(_read_all_tokens($tokenizer)
		   ,'EMPHASIS,STRING,EMPHASIS'
		   ,'Correct tokenization - start with strong');

		$tokenizer->tokenize( 'String //End with emphasis//' );
		is(_read_all_tokens($tokenizer)
		   ,'STRING,EMPHASIS,STRING,EMPHASIS'
		   ,'Correct tokenization - end with emphasis');
	};

	subtest "Underline" => sub {
		$tokenizer->tokenize( '__Start with underline__' );
		is(_read_all_tokens($tokenizer)
		   ,'UNDERLINE,STRING,UNDERLINE'
		   ,'Correct tokenization - start with underline');

		$tokenizer->tokenize( 'String __End with underline__' );
		is(_read_all_tokens($tokenizer)
		   ,'STRING,UNDERLINE,STRING,UNDERLINE'
		   ,'Correct tokenization - end with underline');	
	};

	subtest "Quote" => sub {
		$tokenizer->tokenize( '""Start with quote""' );
		is(_read_all_tokens($tokenizer)
		   ,'QUOTE,STRING,QUOTE'
		   ,'Correct tokenization - start with quote');

		$tokenizer->tokenize( 'String ""Start with quote""' );
		is(_read_all_tokens($tokenizer)
		   ,'STRING,QUOTE,STRING,QUOTE'
		   ,'Correct tokenization - end with quote');
	};
};

# ------------------------------------------------------------------------------

subtest "Markup style markers non-markup" => sub {
	my $tokenizer = PML::Tokenizer->new;	
	$tokenizer->tokenize( 'Text with *strong*, _underline_ and /emphasis/' );
	is(_read_all_tokens($tokenizer)
	   ,'STRING'
	   ,'Correct tokenization');
};

# ------------------------------------------------------------------------------


subtest "Link markup" => sub {
	my $tokenizer = PML::Tokenizer->new;	
	$tokenizer->tokenize( 'Text with [[http://google.com]] in middle' );
	is(_read_all_tokens($tokenizer)
	   ,'STRING,LINK,STRING'
	   ,'Correct tokenization - in string');

	$tokenizer->tokenize( 'End with [[http://google.com]]' );
	is(_read_all_tokens($tokenizer)
	   ,'STRING,LINK'
	   ,'Correct tokenization - end string');

	$tokenizer->tokenize( '[[http://google.com]] at start' );
	is(_read_all_tokens($tokenizer)
	   ,'LINK,STRING'
	   ,'Correct tokenization - start string');

	$tokenizer->tokenize( '[[http://google.com|Google]]' );
	is(_read_all_tokens($tokenizer)
	   ,'LINK'
	   ,'Correct tokenization - link with text');

	$tokenizer->tokenize( '[[http://google.com|Goo]gle]]' );
	is(_read_all_tokens($tokenizer)
	   ,'LINK'
	   ,'Correct tokenization - link with text containing "]"');

	$tokenizer->tokenize( '[abc]' );
	is(_read_all_tokens($tokenizer)
	   ,'STRING'
	   ,'Correct tokenization - plain link delimiters');
};

# ------------------------------------------------------------------------------

subtest "Header markup" => sub {
	my $tokenizer = PML::Tokenizer->new;	
	$tokenizer->tokenize( '##1|Header1## ##2|Header2## ##3|Header3## ##4|Header4##' );	
	is(_read_all_tokens($tokenizer),
	   ,'HEADER,HEADER,HEADER,HEADER'
	   ,'Tokenization of headers1-4');

	$tokenizer->tokenize( '##1|Header1## This is now some content' );	
	is(_read_all_tokens($tokenizer),
	   ,'HEADER,STRING'
	   ,'Header then paragraph');

	$tokenizer->tokenize( 'Some content ##1|Header1##' );	
	is(_read_all_tokens($tokenizer),
	   ,'STRING,HEADER'
	   ,'Paragraph then header');

	dies_ok { $tokenizer->tokenize( '##a|H##' ) } 'Dies with bad header level (non numeric)';

	subtest "Header token content" => sub {
		$tokenizer->tokenize( '##3|abc##' );
		my $token = $tokenizer->get_next_token;
		is($token->{type}, 'HEADER', 'Type == HEADER');
		is($token->{level},'3',		 'Level == 3');
		is($token->{text}, 'abc',	 'Text == abc');
	};
};

# ------------------------------------------------------------------------------

subtest "Image markup" => sub {
	my $tokenizer = PML::Tokenizer->new;	
	$tokenizer->tokenize( '{{image.png}}' );
	is(_read_all_tokens($tokenizer)
	   ,'IMAGE'
	   ,'Simple image with no options');

	$tokenizer->tokenize( 'String then {{image.png}}' );
	is(_read_all_tokens($tokenizer)
	   ,'STRING,IMAGE'
	   ,'Image after string');


	subtest "Error states" => sub {
		dies_ok {$tokenizer->tokenize('{{img.png|}a}}')} "Dies when } in options";
		dies_ok {$tokenizer->tokenize('{{img.png|Ha}}')} "Dies when bad height digit";
		dies_ok {$tokenizer->tokenize('{{img.png|Wa}}')} "Dies when bad width digit";

		lives_ok {$tokenizer->tokenize('{{a|H1}}')} "Height option end of tag ok";
		lives_ok {$tokenizer->tokenize('{{a|W1}}')} "Width option end of tag ok";
	};

	subtest "Image token content" => sub {
		$tokenizer->tokenize( '{{image.png|W50,H100,<<}}' );
		my $token = $tokenizer->get_next_token;
		is($token->{type}, 	'IMAGE', 	 'Type == IMAGE'	);
		is($token->{src},  	'image.png', 'Src == image.png'	);		
		is($token->{height},'100',		 'Height == 100'	);
		is($token->{width}, '50',		 'Width == 50'		);
		is($token->{align}, 'left',		 'Align == left'	);
	};

	subtest "Image alignments" => sub {
		is($tokenizer->tokenize( '{{a|<<}}' )->get_next_token->{align}, 'left',  'Left align');
		is($tokenizer->tokenize( '{{a|>>}}' )->get_next_token->{align}, 'right', 'Right align');
		is($tokenizer->tokenize( '{{a|><}}' )->get_next_token->{align}, 'center','Center align');
		is($tokenizer->tokenize( '{{a|<>}}' )->get_next_token->{align}, 'span',  'Span align');
	};
};

# ------------------------------------------------------------------------------

subtest "Paragraph break" => sub {
	my $tokenizer = PML::Tokenizer->new;	
	$tokenizer->tokenize( "Para1\n\nPara2" );	
	is(_read_all_tokens($tokenizer),
	   ,'STRING,PARA,STRING'
	   ,'Simple paragraph break');

	$tokenizer->tokenize( "Para1\nSame para" );	
	is(_read_all_tokens($tokenizer),
	   ,'STRING,LINE_BREAK,STRING'
	   ,'Simple line break');
};

# ------------------------------------------------------------------------------

subtest "Rows and columns" => sub {
	my $tokenizer = PML::Tokenizer->new;	

	subtest "Plain rows" => sub {
		$tokenizer->tokenize( '@@New row!@@' );
		is(_read_all_tokens($tokenizer),'ROW,STRING,ROW', ,'Simple row at start of data');

		$tokenizer->tokenize( 'Some stuff@@New row!@@' );
		is(_read_all_tokens($tokenizer),'STRING,ROW,STRING,ROW', ,'Simple row after data');
	};

	subtest "Rows with columns (what they were meant for!)" => sub {
		$tokenizer->tokenize( '@@ ||Col1 ||Col2@@' );
		is(_read_all_tokens($tokenizer),
		   ,'ROW,COLUMN,STRING,COLUMN,STRING,ROW'
		   ,'Row with columns');
	};
};

# ------------------------------------------------------------------------------

done_testing();

# ==============================================================================

# Util: read all available tokens and return array
sub _read_all_tokens {
	my ($tokenizer) = @_;
	my @tokens = @{$tokenizer->tokens};	
	return wantarray ? @tokens : join ',',(map { $_->{type} } @tokens);
}

# ------------------------------------------------------------------------------

