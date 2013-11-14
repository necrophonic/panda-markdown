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


is(
	PML::markdown(qq|Para1\n\nPara2\n\nPara3|)
	,"<p>Para1</p><p>Para2</p><p>Para3</p>\n"
	,"New paragraphs"
);


is(
	PML::markdown(qq|Line1\nLine2|)
	,"<p>Line1<br>Line2</p>\n"
	,'Single newline gives break'
);


is(
	PML::markdown(qq|Line1\n \nLine2|)
	,"<p>Line1<br> <br>Line2</p>\n"
	,'Chained newline breaks'
);


is(
	PML::markdown(qq!Click [[http://google.com|here]]!)
	,qq|<p>Click <a href="http://google.com" target="_new">here</a></p>\n|
	,"Simple link"
);

is(
	PML::markdown(qq!Click [[/assets/img.png|here]]!)
	,qq|<p>Click <a href="/assets/img.png">here</a></p>\n|
	,"Internal link"
);


is(
	PML::markdown(qq!{{http://test.com/images/abc.png}}!)
	,qq|<img src="http://test.com/images/abc.png">\n|
	,"Simple image"
);

is(
	PML::markdown(qq!{{/images/abc.png|<<,H50,W50}}!)
	,qq|<img class="pulled-left" src="/images/abc.png" height="50px" width="50px">\n|
	,"Image with options"
);

is(
	PML::markdown(qq!{{/images/abc.png}}!)
	,qq|<img src="/images/abc.png">\n|
	,"Simple image"
);

is(
	PML::markdown(qq!See this:{{/images/abc.png}}Nice, wasn't it?!)
	,qq|<p>See this:</p><img src="/images/abc.png"><p>Nice, wasn&#39;t it?</p>\n|
	,"Image surrounded by blocks"
);


is(
	PML::markdown(q!@@A simple block@@!)
	,qq|<div class="clearfix"><p>A simple block</p></div>\n|
	,'Simple block with no modifiers'
);

is(
	PML::markdown(q!@@[C2]||Left col||||Right col||@@!)
	,qq|<div class="clearfix col-2"><div><p>Left col</p></div><div><p>Right col</p></div></div>\n|
	,'Simple with modifiers'
);

# is(
# 	PML::markdown(q!One line\\Next line\\Third line!)
# 	,qq|<p>One line<br>Next line<br><br>Third line</p>|
# 	,'Simple line breaks'

# );


done_testing();
exit(0);

# ------------------------------------------------------------------------------
