#!/usr/bin/env perl
use strict;
use Test::More;
use Test::Exception;

use_ok 'PML::HTMLFormatter';

{
	my $formatter = new_ok 'PML::HTMLFormatter';

	isa_ok($formatter->tokenizer,'PML::Tokenizer');

	dies_ok { $formatter->format } "Dies when no pml supplied to format()";
}

subtest "Simple text to paragaph" => sub {
	my $formatter = PML::HTMLFormatter->new;
	my $html = $formatter->format('Some basic text!');
	is($html,'<p>Some basic text!</p>','Plain text');
};


subtest "Simple style formatting" => sub {
	my $formatter = PML::HTMLFormatter->new;
	is($formatter->format('**strong**, __underline__, //emphasis//, ""quote""')
	  ,q|<p><strong>strong</strong>, <u>underline</u>, <em>emphasis</em>, <blockquote>quote</blockquote></p>|
	  ,'PML with strong, underline and emphasis');
};


subtest "Paragraphs" => sub {
	my $formatter = PML::HTMLFormatter->new;
	is($formatter->format("Paragraph then\n\nNew paragaph")
	  ,q|<p>Paragraph then</p><p>New paragaph</p>|
	  ,'Paragraph break');

	is($formatter->format("Paragraph then\nline break")
	  ,q|<p>Paragraph then<br>line break</p>|
	  ,'Newline break');
};


subtest "Links" => sub {
	my $formatter = PML::HTMLFormatter->new;
	is($formatter->format("[[http://google.com]]")
	  ,q|<p><a href="http://google.com">http://google.com</a></p>|
	  ,'Simple link');

	is($formatter->format("[[http://google.com|Google]]")
	  ,q|<p><a href="http://google.com">Google</a></p>|
	  ,'Simple link with alt text');

	is($formatter->format("Text [[a]] Other Text")
	  ,q|<p>Text <a href="a">a</a> Other Text</p>|
	  ,'Link in existing paragaph');
};


subtest "Images" => sub {
	my $formatter = PML::HTMLFormatter->new;
	is($formatter->format('{{http://a.com/abc.png}}')
	  ,q|<p><img src="http://a.com/abc.png"></p>|
	  ,"Absolute image with no options");

	is($formatter->format('{{abc.png}}')
	  ,q|<p><img src="abc.png"></p>|
	  ,"Relative image with no options");

	is($formatter->format('{{abc.png|<<}}')
	  ,q|<img src="abc.png" class="pulled-left">|
	  ,"Image with align left");

	is($formatter->format('{{abc.png|>>}}')
	  ,q|<img src="abc.png" class="pulled-right">|
	  ,"Image with align right");

	is($formatter->format('{{abc.png|<>}}')
	  ,q|<img src="abc.png" class="stretch-horiz">|
	  ,"Image with stretch horizontal");

	is($formatter->format('{{abc.png|><}}')
	  ,q|<img src="abc.png" class="centered">|
	  ,"Image centered");

	is($formatter->format('{{abc.png|W10,H20}}')
	  ,q|<p><img src="abc.png" width="10px" height="20px"></p>|
	  ,"Image with dimensions");
};


subtest "Headers" => sub {
	my $formatter = PML::HTMLFormatter->new;
	is($formatter->format('##1|Blah##')
	  ,q|<h1>Blah</h1>|
	  ,"Independant header (level 1)");

	is($formatter->format('##2|Blah##')
	  ,q|<h2>Blah</h2>|
	  ,"Independant header (level 2)");

	is($formatter->format('##3|Blah##')
	  ,q|<h3>Blah</h3>|
	  ,"Independant header (level 3)");
};


done_testing();
