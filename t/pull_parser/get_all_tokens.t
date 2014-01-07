#!/usr/bin/env perl

use strict;

use Test::More;
use Test::Exception;

use Readonly;
Readonly my $CLASS => 'Text::CaffeinatedMarkup::PullParser';

use_ok $CLASS;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($OFF);

my $parser;

	subtest "Simple parse" => sub {
		$parser = $CLASS->new(pml => 'Simple **PML** to parse');
		my @tokens = ();
		lives_ok {@tokens = $parser->get_all_tokens()}, 'Parse without error';	
	};
			
	test_section_break_markup();	
	test_escaping_markup();


done_testing();

# ==============================================================================

sub get_tokens_string {	join ',', map { $_->{type} } @{$_[0]}; }

# ------------------------------------------------------------------------------

sub test_newline_markup {
	subtest "Test newline markup" => sub {

		my @tokens = ();

		

	};
	return;
}

# ------------------------------------------------------------------------------

sub test_section_break_markup {
	subtest "Test section_break markup" => sub {

		subtest "Simple section break" => sub {
			$parser = $CLASS->new(pml => '~~');
			my @tokens = $parser->get_all_tokens;
			is(get_tokens_string(\@tokens),'SECTIONBREAK','Section break');	
		};
	};
}

# ------------------------------------------------------------------------------

sub test_escaping_markup {
	subtest "Test escaping markup" => sub {

		my @tokens = ();

		subtest "Backslash escaping" => sub {
		 	$parser = $CLASS->new(pml => 'Take this \**literally\**');
		 	@tokens = $parser->get_all_tokens;
		 	is get_tokens_string(\@tokens), 'STRING', 			 'Escape strong - tokens';
		 	is $tokens[0]->{content}, 'Take this **literally**', 'Escape strong - content';

			$parser = $CLASS->new(pml => 'Take this \//literally\//');
			@tokens = $parser->get_all_tokens;
			is get_tokens_string(\@tokens), 'STRING', 			 'Escape emphasis - tokens';
			is $tokens[0]->{content}, 'Take this //literally//', 'Escape emphasis - content';

			$parser = $CLASS->new(pml => 'Take this \--literally\--');
			@tokens = $parser->get_all_tokens;
			is get_tokens_string(\@tokens), 'STRING', 			 'Escape delete - tokens';
			is $tokens[0]->{content}, 'Take this --literally--', 'Escape delete - content';

			$parser = $CLASS->new(pml => 'Take this \__literally\__');
			@tokens = $parser->get_all_tokens;
			is get_tokens_string(\@tokens), 'STRING', 			 'Escape underline - tokens';
			is $tokens[0]->{content}, 'Take this __literally__', 'Escape underline - content';

			$parser = $CLASS->new(pml => 'Take this \{{literally}}');
			@tokens = $parser->get_all_tokens;
			is get_tokens_string(\@tokens), 'STRING', 			 'Escape image (opening set) - tokens';
			is $tokens[0]->{content}, 'Take this {{literally}}', 'Escape image (opening set) - content';

			$parser = $CLASS->new(pml => 'Take this \{{literally\}}');
			@tokens = $parser->get_all_tokens;
			is get_tokens_string(\@tokens), 'STRING', 			 'Escape image (both sets) - tokens';			
			is $tokens[0]->{content}, 'Take this {{literally}}', 'Escape image (both sets) - content';
		};

		subtest "Region escaping" => sub {
			$parser = $CLASS->new(pml => '%%**//__{{}}[[]]%%');
			@tokens = $parser->get_all_tokens;
			is get_tokens_string(\@tokens), 'STRING',   'region escape - tokens';
			is $tokens[0]->{content}, '**//__{{}}[[]]', 'region escape - content';
		};

		subtest "Escape escaping" => sub {
			$parser = $CLASS->new(pml => "\\\\");
			@tokens = $parser->get_all_tokens;
			is get_tokens_string(\@tokens), 'STRING', 'backslash escape escape - tokens';
			is $tokens[0]->{content}, '\\',           'baskslash escape escape - content';

			$parser = $CLASS->new(pml => "\\%%");
			@tokens = $parser->get_all_tokens;
			is get_tokens_string(\@tokens), 'STRING', 'backslash region escape - tokens';
			is $tokens[0]->{content}, '%%',           'baskslash region escape - content';
		};

		subtest "Escaping in images" => sub {
			subtest "Backslash escape in src" => sub {
				$parser = $CLASS->new(pml => '{{ima\__ge.jpg}}');
				@tokens = $parser->get_all_tokens;
				is get_tokens_string(\@tokens), 'IMAGE', 'image token ok';
				is $tokens[0]->{src}, 'ima__ge.jpg', 'image src ok';
			};

			subtest "Backslash escape in both" => sub {
				$parser = $CLASS->new(pml => '{{ima\__ge.jpg|\**,>>}}');
				@tokens = $parser->get_all_tokens;
				is get_tokens_string(\@tokens), 'IMAGE', 'image token ok';
				is $tokens[0]->{src},     'ima__ge.jpg', 'image src ok';
				is $tokens[0]->{options}, '**,>>',       'image options ok';
			};

			subtest "Backslash escape in options" => sub {
				$parser = $CLASS->new(pml => '{{image.jpg|\**,>>}}');				
				@tokens = $parser->get_all_tokens;
				is get_tokens_string(\@tokens), 'IMAGE', 'image token ok';
				is $tokens[0]->{src}, 'image.jpg', 		 'image src ok';
				is $tokens[0]->{options}, '**,>>', 		 'image options ok';
			};
		};

		subtest "Escaping in hyperlinks" => sub {
			subtest "Backslash escape in href" => sub {
				$parser = $CLASS->new(pml => '[[som\%%where]]');
				@tokens = $parser->get_all_tokens;
				is get_tokens_string(\@tokens), 'LINK', 'link token ok';
				is $tokens[0]->{href},	'som%%where', 	'link href ok';
			};

			subtest "Backslash escape in both" => sub {
				$parser = $CLASS->new(pml => '[[som\%%where|\**here]]');
				@tokens = $parser->get_all_tokens;
				is get_tokens_string(\@tokens), 'LINK', 'link token ok';
				is $tokens[0]->{href},	'som%%where', 	'link href ok';
				is $tokens[0]->{text},	'**here', 		'link text ok';
			};

			subtest "Backslash escape in text" => sub {
				$parser = $CLASS->new(pml => '[[somewhere|\**here]]');
				@tokens = $parser->get_all_tokens;
				is get_tokens_string(\@tokens), 'LINK', 'link token ok';
				is $tokens[0]->{href},	'somewhere', 	'link href ok';
				is $tokens[0]->{text},	'**here', 		'link text ok';
			};
		};

	};
}

# ------------------------------------------------------------------------------
