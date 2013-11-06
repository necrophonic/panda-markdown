use v5.10;

use strict;
use warnings;

use Test::More;
use PML;


note("Test 1");
is(
	PML::markdown(qq|##Heading1##\n\n###Heading2###\n\n####Heading3####\n|)
	,"<h1>Heading1</h1><h2>Heading2</h2><h3>Heading3</h3>\n"
	,'Output HTML as expected'
);

note("Test 2");
is(
	PML::markdown(q|This should ""quote""|)
	,"<p>This should <blockquote>quote</blockquote></p>\n"
	,"Html with quote tags"
);

note("Test 3");
is(
	PML::markdown(q|**Bold**, //Italic//, __Underline__|)
	,"<p><strong>Bold</strong>, <em>Italic</em>, <u>Underline</u></p>\n"
	,"Basic formatting"
);

note("Test 4");
is(
	PML::markdown(qq|Para1\n\nPara2\n\nPara3|)
	,"<p>Para1</p><p>Para2</p><p>Para3</p>\n"
	,"New paragraphs"
);

note("Test 5 - link");
is(
	PML::markdown(qq!Click [[http://google.com|here]]!)
	,qq|<p>Click <a href="http://google.com">here</a></p>\n|
	,"Simple link"
);

done_testing();
exit(0);

# ------------------------------------------------------------------------------
