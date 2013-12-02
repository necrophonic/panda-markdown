#!/usr/bin/env perl

use strict;

use Test::More;
use Test::Exception;

use Readonly;
Readonly my $CLASS => 'PML::PullParser';

use_ok $CLASS;

use Log::Log4perl qw(:easy);
#Log::Log4perl->easy_init($OFF);

my $parser;

	subtest "Simple parse" => sub {
		$parser = $CLASS->new(pml => 'Simple **PML** to parse');
		my @tokens = ();
		lives_ok {@tokens = $parser->get_all_tokens()}, 'Parse without error';	
	};

	test_simple_markup();
	test_link_markup();
	test_image_markup();
	test_newline_markup();
	test_header_markup();


done_testing();

# ==============================================================================

sub get_tokens_string {
	my ($tokens_r) = @_;
	my @types;
	for (@$tokens_r) { push @types, $_->{type} }
	return join ',',@types;
}

# ------------------------------------------------------------------------------

sub test_simple_markup {

	subtest "Test simple markup" => sub {

		subtest "Strong" => sub {
			$parser = $CLASS->new(pml => 'Simple **PML** to parse');
			my @tokens = $parser->get_all_tokens;
			is( get_tokens_string(\@tokens), 'STRING,STRONG,STRING,STRONG,STRING', 'Strong in string' );
			is($tokens[0]->{content}, 'Simple ',   'Token #1 correct text'	);
			is($tokens[1]->{type}, 	  'STRONG',    'Token #2 is STRONG'		);
			is($tokens[2]->{content}, 'PML', 	   'Token #3 correct text'	);
			is($tokens[3]->{type}, 	  'STRONG',    'Token #4 is STRONG'		);
			is($tokens[4]->{content}, ' to parse', 'Token #5 correct text'	);


			$parser = $CLASS->new(pml => '**Strong** at start');
			my @tokens = $parser->get_all_tokens;
			is( get_tokens_string(\@tokens), 'STRONG,STRING,STRONG,STRING', 'Strong at start' );

			$parser = $CLASS->new(pml => 'At the end is **Strong**');
			my @tokens = $parser->get_all_tokens;
			is( get_tokens_string(\@tokens), 'STRING,STRONG,STRING,STRONG', 'Strong at end' );
		};

		subtest "Emphasis" => sub {
			$parser = $CLASS->new(pml => 'With //emphasis// in middle');
			my @tokens = $parser->get_all_tokens;
			is( get_tokens_string(\@tokens), 'STRING,EMPHASIS,STRING,EMPHASIS,STRING', 'Emphasis in string' );

			$parser = $CLASS->new(pml => '//Emphasis// at start');
			my @tokens = $parser->get_all_tokens;
			is( get_tokens_string(\@tokens), 'EMPHASIS,STRING,EMPHASIS,STRING', 'Emphasis at start' );

			$parser = $CLASS->new(pml => 'At the end is //emphasis//');
			my @tokens = $parser->get_all_tokens;
			is( get_tokens_string(\@tokens), 'STRING,EMPHASIS,STRING,EMPHASIS', 'Emphasis at end' );
		};

		subtest "Underline" => sub {
			$parser = $CLASS->new(pml => 'With __underline__ in middle');
			my @tokens = $parser->get_all_tokens;
			is( get_tokens_string(\@tokens), 'STRING,UNDERLINE,STRING,UNDERLINE,STRING', 'Underline in string' );

			$parser = $CLASS->new(pml => '__underline__ at start');
			my @tokens = $parser->get_all_tokens;
			is( get_tokens_string(\@tokens), 'UNDERLINE,STRING,UNDERLINE,STRING', 'Underline at start' );

			$parser = $CLASS->new(pml => 'At the end is __underline__');
			my @tokens = $parser->get_all_tokens;
			is( get_tokens_string(\@tokens), 'STRING,UNDERLINE,STRING,UNDERLINE', 'Underline at end' );
		};

		subtest "Del" => sub {
			$parser = $CLASS->new(pml => 'With --del-- in middle');
			my @tokens = $parser->get_all_tokens;
			is( get_tokens_string(\@tokens), 'STRING,DEL,STRING,DEL,STRING', 'Del in string' );

			$parser = $CLASS->new(pml => '--del-- at start');
			my @tokens = $parser->get_all_tokens;
			is( get_tokens_string(\@tokens), 'DEL,STRING,DEL,STRING', 'Del at start' );

			$parser = $CLASS->new(pml => 'At the end is --del--');
			my @tokens = $parser->get_all_tokens;
			is( get_tokens_string(\@tokens), 'STRING,DEL,STRING,DEL', 'Del at end' );
		};
	};
	return;
}

# ------------------------------------------------------------------------------

sub test_link_markup {
	subtest "Test link markup" => sub {

		subtest "Simple link" => sub {
			$parser = $CLASS->new(pml => "Go here [[http://www.google.com]] it's cool");
			my @tokens = $parser->get_all_tokens;
			is(get_tokens_string(\@tokens),'STRING,LINK,STRING','Link with just href');
			is($tokens[1]->{href}, 'http://www.google.com', 'Href set ok');
			is($tokens[1]->{text}, '', 'Text is null');
		};

		subtest "Simple link with text" => sub {
			$parser = $CLASS->new(pml => "Go here [[http://www.google.com|Google]] it's cool");
			my @tokens = $parser->get_all_tokens;
			is(get_tokens_string(\@tokens),'STRING,LINK,STRING','Link with text');
			is($tokens[1]->{href}, 'http://www.google.com', 'Href set ok');
			is($tokens[1]->{text}, 'Google', 'Text set ok');
		};

	};
	return;
}

# ------------------------------------------------------------------------------

sub test_image_markup {
	subtest "Test image markup" => sub {

		subtest "Simple image" => sub {
			$parser = $CLASS->new(pml => "Look at this {{cat.jpg}} Nice huh?");
			my @tokens = $parser->get_all_tokens;
			is(get_tokens_string(\@tokens),'STRING,IMAGE,STRING','Image with just src');
			is($tokens[1]->{src}, 'cat.jpg', 'Src set ok');
			is($tokens[1]->{options}, '', 'Options is null');
		};

		subtest "Simple image with options" => sub {
			$parser = $CLASS->new(pml => "Look at this {{cat.jpg|>>,W29}} Nice huh?");
			my @tokens = $parser->get_all_tokens;
			is(get_tokens_string(\@tokens),'STRING,IMAGE,STRING','Image with just src');
			is($tokens[1]->{src}, 'cat.jpg', 'Src set ok');
			is($tokens[1]->{options}, '>>,W29', 'Options set ok');
		};

	};
	return;
}

# ------------------------------------------------------------------------------

sub test_header_markup {
	subtest "Test header markup" => sub {

		subtest "Simple headers 1-6" => sub {
			$parser = $CLASS->new(pml => qq|# Header level 1|);
			my @tokens = $parser->get_all_tokens;
			is(get_tokens_string(\@tokens),'HEADER','Header token');
			is($tokens[0]->{level},1,'Header level is 1');
			is($tokens[0]->{text},'Header level 1', 'Header text is correct');
		};

		subtest "In line becomes string" => sub {
			$parser = $CLASS->new(pml => qq|String then # Header level 1|);
			my @tokens = $parser->get_all_tokens;
			is(get_tokens_string(\@tokens),'STRING','Just a string token');
			is($tokens[0]->{content},'String then # Header level 1', 'Content correct');
		};

	};
}

# ------------------------------------------------------------------------------

sub test_newline_markup {
	subtest "Test newline markup" => sub {

		subtest "Single newline" => sub {
			$parser = $CLASS->new(pml => "First line\nSecond line");
			my @tokens = $parser->get_all_tokens;
			is(get_tokens_string(\@tokens),'STRING,NEWLINE,STRING','Single newline in string');
		};

		subtest "Double newline" => sub {
			$parser = $CLASS->new(pml => "First line\n\nSecond line");
			my @tokens = $parser->get_all_tokens;
			is(get_tokens_string(\@tokens),'STRING,NEWLINE,NEWLINE,STRING','Double newline in string');
		};

	};
	return;
}

# ------------------------------------------------------------------------------