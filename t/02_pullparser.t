#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;

use Test::More;
use Test::Exception;

package Test;
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

    before 'tokenize' => sub {
        my ($self) = @_;
        $self->tokens([]);
    };
	
package main;

#plan tests => 10;

	use_ok 'Text::CaffeinatedMarkup::PullParser';
	can_ok 'Text::CaffeinatedMarkup::PullParser', qw|tokenize|;	

    my $pp = Test->new;

    test_emphasis();
    test_hyperlinks();
    test_images();
    test_headers();
    test_escaping();
    test_dividers();
    test_breaks();

    # Not public interface things, but stuff to verify
    # that the internals do what they should!
    test_peek();
	


done_testing;

# -----------------------------------------------------------------------------

sub test_emphasis {
    subtest 'emphasis' => sub {
        plan tests => 2;

    	subtest 'Simple mixed emphasis' => sub {
    		plan tests => 5;
    		$pp->tokenize('The **cat** sat __on__ the //mat//');
    		test_expected_tokens_list(
    			$pp->tokens,
    			[qw|text emphasis text emphasis text emphasis text emphasis text emphasis text emphasis|]
    		);
    		# Check the content of some tokens
    		is $pp->tokens->[0]->content, 'The ';
    		is $pp->tokens->[1]->type,    'strong';
    		is $pp->tokens->[5]->type,    'underline';
    		is $pp->tokens->[9]->type,    'emphasis';
    	};
    
    	subtest 'Emphasis at start of parse' => sub {
    		plan tests => 4;
            $pp->tokenize('**Yay!**');
    		test_expected_tokens_list( $pp->tokens, [qw|emphasis text emphasis|] );
    		is $pp->tokens->[1]->content, 'Yay!';
    		is $pp->tokens->[0]->type,    'strong';
    		is $pp->tokens->[2]->type,    'strong';
    	};
    };
}

# ------------------------------------------------------------------------------

sub test_hyperlinks {
    subtest 'test hyperlinks' => sub {
        plan tests => 3;

     	subtest 'Hyperlink with alt text' => sub {
    		plan tests => 3;
    		$pp->tokenize('Go here: [[http://www.example.com|example site]]');
    		test_expected_tokens_list( $pp->tokens, [qw|text link|] );
    		is $pp->tokens->[1]->href, 'http://www.example.com', 'href is correct';
    		is $pp->tokens->[1]->text, 'example site', 'text is correct';
    	};
    
    	subtest 'Hyperlink with no alt text' => sub {
    		plan tests => 3;
    		$pp->tokenize('Go here: [[http://www.example.com]]');
    		test_expected_tokens_list( $pp->tokens, [qw|text link|] );
    		is $pp->tokens->[1]->href, 'http://www.example.com', 'href is correct';
    		is $pp->tokens->[1]->text, '', 'text is correct';
    	};   

        subtest 'Hyperlink at start of parse' => sub {
    		plan tests => 3;
    		$pp->tokenize('[[http://www.example.com]]');
    		test_expected_tokens_list( $pp->tokens, [qw|link|] );
    		is $pp->tokens->[0]->href, 'http://www.example.com', 'href is correct';
    		is $pp->tokens->[0]->text, '', 'text is correct';
    	};   
    };
}

# ------------------------------------------------------------------------------

sub test_images {
    subtest 'test images' => sub {
        plan tests => 3;

	    subtest 'Image with options' => sub {
	    	plan tests => 3;
	    	$pp->tokenize('{{images/cat.jpg|>>,W100,H50}}');
	    	test_expected_tokens_list( $pp->tokens, [qw|image|] );
	    	is $pp->tokens->[0]->src, 'images/cat.jpg', 'src is correct';
	    	is $pp->tokens->[0]->options, '>>,W100,H50', 'options is correct';
	    };

	    subtest 'Image without options' => sub {
	    	plan tests => 3;
	    	$pp->tokenize('{{images/cat.jpg}}');
	    	test_expected_tokens_list( $pp->tokens, [qw|image|] );
	    	is $pp->tokens->[0]->src, 'images/cat.jpg', 'src is correct';
	    	is $pp->tokens->[0]->options, '', 'options is correct';
	    };

        subtest 'Image in text' => sub {
	    	plan tests => 3;
	    	$pp->tokenize('A cat {{images/cat.jpg}} That was nice');
	    	test_expected_tokens_list( $pp->tokens, [qw|text image text|] );
	    	is $pp->tokens->[1]->src, 'images/cat.jpg', 'src is correct';
	    	is $pp->tokens->[1]->options, '', 'options is correct';
	    };
    };
}

# ------------------------------------------------------------------------------

sub test_peek {
    subtest 'Peek' => sub {
        plan tests => 3;

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
}

# ------------------------------------------------------------------------------

sub test_headers {
	subtest 'test headers' => sub {
		plan tests => 4;
		$pp->tokenize('# Header');
		test_expected_tokens_list( $pp->tokens, [qw|header|] );
		is $pp->tokens->[0]->level, 1, 'level is correct (1)';		

		$pp->tokenize('### Header');
		test_expected_tokens_list( $pp->tokens, [qw|header|] );
		is $pp->tokens->[0]->level, 3, 'level is correct (3)';
	};
}

# ------------------------------------------------------------------------------

sub test_escaping {
    subtest 'test escaping' => sub {
		plan tests => 3;
		$pp->tokenize('\**cat \***dog**');
		test_expected_tokens_list( $pp->tokens, [qw|text emphasis text emphasis|] );
		is $pp->tokens->[0]->content, '**cat *', 'content is correct';
		is $pp->tokens->[2]->content, 'dog',    'content is correct';
	};
}

# ------------------------------------------------------------------------------

sub test_dividers {
    subtest 'test dividers' => sub {
		plan tests => 1;
		$pp->tokenize("~~");
		test_expected_tokens_list( $pp->tokens, [qw|divider|] );
	};
}

# ------------------------------------------------------------------------------

sub test_breaks {
    subtest 'test breaks' => sub {
		plan tests => 5;

		$pp->tokenize("Text\nText after");
		test_expected_tokens_list( $pp->tokens, [qw|text line_break text|] );
		is $pp->tokens->[2]->content, 'Text after', 'text ok';

		$pp->tokenize("Text\n\nText after");
		test_expected_tokens_list( $pp->tokens, [qw|text paragraph_break text|] );

		$pp->tokenize("Text\n\n\n\n\nMore Text after");
		test_expected_tokens_list( $pp->tokens, [qw|text paragraph_break text|] );
		is $pp->tokens->[2]->content, 'More Text after', 'text ok';
	};
}

# ------------------------------------------------------------------------------

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
