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

subtest "Plain control chars" => sub {
	my $formatter = PML::HTMLFormatter->new;
	is($formatter->format('*a"a/a"a_a')
	  ,q|<p>*a"a/a"a_a</p>|
	  ,'Plain chars output as string text');
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
	  ,q|<p><a href="http://google.com" target="_new">http://google.com</a></p>|
	  ,'Simple external link');

	is($formatter->format("[[/assets/something]]")
	  ,q|<p><a href="/assets/something">/assets/something</a></p>|
	  ,'Simple internal link');

	is($formatter->format("[[http://google.com|Google]]")
	  ,q|<p><a href="http://google.com" target="_new">Google</a></p>|
	  ,'Simple external link with alt text');

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

	subtest "Bad header sequence" => sub {
		is($formatter->format('#39')
	  	  ,q|<p>#39</p>|
	  	  ,"Single hash becomes string");	
	};
};


subtest "Rows and columns" => sub {
	my $formatter = PML::HTMLFormatter->new;
	is($formatter->format('@@||a||b@@')
	  ,q|<div class="clearfix col-2"><div class="column"><p>a</p></div><div class="column"><p>b</p></div></div>|
	  ,"2-col row");
};


done_testing();