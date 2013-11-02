use v5.10;

use strict;
use warnings;

use Test::More;
use PML;


is(
	PML::markdown(qq|##Heading1##\n\n###Heading2###\n\n####Heading3####\n|)
	,"<h1>Heading1</h1><h2>Heading2</h2><h3>Heading3</h3>\n"
	,'Output HTML as expected'
);

is(
	PML::markdown(q|This should ""quote""|)
	,"<p>This should <blockquote>quote</blockquote></p>\n"
	,"Html with quote tags"
);

is(
	PML::markdown(q|**Bold**, //Italic//, __Underline__|)
	,"<p><strong>Bold</strong>, <em>Italic</em>, <u>Underline</u></p>\n"
	,"Basic formatting"
);

done_testing();
exit(0);

# ------------------------------------------------------------------------------
