#!/usr/bin/perl
use strict;

use Test::More;

use lib 't/lib';
use Helpers;

use Text::CaffeinatedMarkup::PullParser;

plan tests => 2;

    can_ok 'Text::CaffeinatedMarkup::PullParser', qw|handle_media|;

    my $pp = Text::CaffeinatedMarkup::PullParser->new;

    test_simple_image_media();

done_testing();

# ------------------------------------------------------------------------------

sub test_simple_image_media {
    subtest 'test simple image media' => sub {
        plan tests => 6;
    
        subtest 'Image with options' => sub {
    		plan tests => 3;
    		$pp->tokenize('{{images/cat.jpg|>>,W100,H50}}');
    		test_expected_tokens_list( $pp->tokens, [qw|media|] );
    		is $pp->tokens->[0]->src, 'images/cat.jpg', 'src is correct';
    		is $pp->tokens->[0]->options, '>>,W100,H50', 'options is correct';
    	};
    
    	subtest 'Image without options' => sub {
    		plan tests => 3;
    		$pp->tokenize('{{images/cat.jpg}}');
    		test_expected_tokens_list( $pp->tokens, [qw|media|] );
    		is $pp->tokens->[0]->src, 'images/cat.jpg', 'src is correct';
    		is $pp->tokens->[0]->options, '', 'options is correct';
    	};
    
        subtest 'Image in text' => sub {
    		plan tests => 5;
    		$pp->tokenize('A cat {{images/cat.jpg}} That was nice');
    		test_expected_tokens_list( $pp->tokens, [qw|text media text|] );
    		is $pp->tokens->[1]->src, 'images/cat.jpg', 'src is correct';
    		is $pp->tokens->[1]->options, '', 'options is correct';

            $pp->tokenize('A cat {{images/cat.jpg}}');
            test_expected_tokens_list( $pp->tokens, [qw|text media|] );
            is $pp->tokens->[1]->src, 'images/cat.jpg', 'src is correct';            
    	};
        
        subtest 'Image in row' => sub {
    		plan tests => 3;
    		$pp->tokenize(qq|==\n{{images/cat.jpg}}\n==|);
    		test_expected_tokens_list( $pp->tokens, [qw|row media row|] );
    		is $pp->tokens->[1]->src, 'images/cat.jpg', 'src is correct';
    		is $pp->tokens->[1]->options, '', 'options is correct';
    	};

        subtest 'Image with caption' => sub {
            plan tests => 1;
            $pp->tokenize(qq!{{cat.jpg|"It's a cat"}}!);
            is $pp->tokens->[0]->caption, "It's a cat", 'caption correct';
        };

        subtest 'Image with caption including double quote' => sub {
            plan tests => 1;
            $pp->tokenize(qq!{{cat.jpg|"It's "a cat"}}!);
            is $pp->tokens->[0]->caption, q|It's "a cat|, 'caption correct';
        };
    };
}

# ------------------------------------------------------------------------------

