#!/usr/bin/env perl

use strict;
use Test::More;

use_ok 'PML::HTMLFormatter';

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($OFF);

	can_ok('PML::HTMLFormatter',qw|format _match_tag|);

	test_simple();
	test_headers();
	test_links();
	test_images();
#	test_full_doc_1();

	# TESTS TO DO
	# .. html escape
	# .. entity escape

done_testing();


# ==============================================================================

sub test_simple {
	subtest "Simple markup test" => sub {
		my $parser = PML::HTMLFormatter->new;
		is($parser->format('**abc**'),'<p><strong>abc</strong></p>','Strong');
		is($parser->format('//abc//'),'<p><em>abc</em></p>','Emphasis');
		is($parser->format('__abc__'),'<p><u>abc</u></p>','Underline');
		is($parser->format('--abc--'),'<p><del>abc</del></p>','Delete');
	};
}

# ------------------------------------------------------------------------------

sub test_headers {
	subtest "Simple markup test" => sub {
		my $parser = PML::HTMLFormatter->new;
		is($parser->format('# My header'),	"\n<h1>My header</h1>\n",'Header 1');
		is($parser->format('## My header'),	"\n<h2>My header</h2>\n",'Header 2');
		is($parser->format('### My header'),"\n<h3>My header</h3>\n",'Header 3');
	};
}

# ------------------------------------------------------------------------------

sub test_links {
	subtest "Simple links" => sub {
		my $parser = PML::HTMLFormatter->new;
		is($parser->format('[[http://here.com]]'),
			'<a href="http://here.com" target="_new">http://here.com</a>',
			'Simple link - no text');

		is($parser->format('[[http://here.com|HERE]]'),
			'<a href="http://here.com" target="_new">HERE</a>',
			'Simple link - with text');
	};
}

# ------------------------------------------------------------------------------

sub test_images {
	subtest "Simple images" => sub {
		my $parser = PML::HTMLFormatter->new;
		is($parser->format('{{image.jpg}}'), '<img src="image.jpg">', 'Relative image');
		is($parser->format('{{http://a.com/image.jpg}}'), '<img src="http://a.com/image.jpg">', 'Absolute image');
	};

	subtest "Images with align options" => sub {
		my $parser = PML::HTMLFormatter->new;
		is($parser->format('{{i.jpg|<<}}'), '<img src="i.jpg" class="pulled-left">',  'Pull left');
		is($parser->format('{{i.jpg|>>}}'), '<img src="i.jpg" class="pulled-right">', 'Pull right');
		is($parser->format('{{i.jpg|><}}'), '<img src="i.jpg" class="centered">', 	  'Centered');
		is($parser->format('{{i.jpg|<>}}'), '<img src="i.jpg" class="stretched">', 	  'Stretched');
	};

	subtest "Images with width options" => sub {
		my $parser = PML::HTMLFormatter->new;
		is($parser->format('{{i.jpg|W10}}'), '<img src="i.jpg" width="10px">', 'Width 10');
		is($parser->format('{{i.jpg|W9}}'),  '<img src="i.jpg" width="9px">',  'Width 9');		
	};

	subtest "Images with height options" => sub {
		my $parser = PML::HTMLFormatter->new;
		is($parser->format('{{i.jpg|H10}}'), '<img src="i.jpg" height="10px">', 'Height 10');
		is($parser->format('{{i.jpg|H9}}'),  '<img src="i.jpg" height="9px">',  'Height 9');		
	};

	subtest "Images with mixed options" => sub {
		my $parser = PML::HTMLFormatter->new;
		is($parser->format('{{i.jpg|<<,W10,H11}}'),
			'<img src="i.jpg" class="pulled-left" width="10px" height="11px">',
			'All options');
	};
}

# ------------------------------------------------------------------------------

sub test_full_doc_1 {
	subtest "Full doc #1" => sub {

		my $input_pml = <<EOT
Yup, we're here! **Caffeinated Panda Creations** has launched the first phase of our new website.

Right now as you can see the blog is up and running and we'll be using it to keep you up to date with projects, events we're involved with, and new features coming to the site. Of course we'll still be streaming updates and content on [[http://facebook.com/caffeinatedpandacreations|facebook]] and [[http://twitter.com/cafpanda|twitter]] as well so come and join us there too!

As time goes on we'll be adding new sections to the website so stay tuned for updates. Upcoming soon will be more details on our creations and services, so here's some things to whet your appetite!
==
||
## Custom Cyberfalls
{{cyberfalls.jpg|<<,H100,W130}}Cyberfalls for all your cybergoth and dance needs, at Caffeinated Panda Creations we specialise in custom designs and sets with [[https://www.google.co.uk/search?q=el+wire&safe=off&tbm=isch|EL-wire]] installations.

Whether you're looking for a themed set for a special occassion or straight forward cyber-chic, get in touch and we'll be happy to work with you!
||
## 3D Printing
{{makerbot.jpg|<<,H100,W130}}We here at Caffeinated Panda Creations are the proud owners of a [[http://store.makerbot.com/replicator2.html|Makerbot Replicator 2]] 3D printer.

As well as using it for our creations we can also offer a bespoke printing service. Design your own objects or let us work with you to create and realise your vision in high quality PLA plastic.
==

==
||
## Emporia
{{etsy.jpg|<<,H100,W130}}Over the next few months we'll be opening our online stores where we'll be selling some of our premade and customisable pieces along with t-shirts and other apparel.

||
## Costuming
{{mask.jpg|<<,H100,W130}}The panda team are keen costumers and going forward will be working on several exciting cosplaying projects for ourselves and others.

We'll also be keeping you up to date on where we'll be appearing and giving details on how we can work with you on your own costuming projects.
==
EOT
;

		my $expected_html =<<EOT
<p>Yup, we're here! <strong>Caffeinated Panda Creations</strong> has launched the first phase of our new website.</p><p>Right now as you can see the blog is up and running and we'll be using it to keep you up to date with projects, events we're involved with, and new features coming to the site. Of course we'll still be streaming updates and content on <a href="http://facebook.com/caffeinatedpandacreations" target="_new">facebook</a> and <a href="http://twitter.com/cafpanda" target="_new">twitter</a> as well so come and join us there too!</p><p>As time goes on we'll be adding new sections to the website so stay tuned for updates. Upcoming soon will be more details on our creations and services, so here's some things to whet your appetite!
<div class="clearfix col-2">
<div class="column">
<h2>Custom Cyberfalls</h2>
<img src="/content/blog/the-panda-cometh/cyberfalls.jpg" class="pulled-left" width="130px" height="100px">Cyberfalls for all your cybergoth and dance needs, at Caffeinated Panda Creations we specialise in custom designs and sets with <a href="https://www.google.co.uk/search?q=el+wire&amp;safe=off&amp;tbm=isch" target="_new">EL-wire</a> installations.</p><p>Whether you're looking for a themed set for a special occassion or straight forward cyber-chic, get in touch and we'll be happy to work with you!</p>
</div>
<div class="column">
<h2>3D Printing</h2>
<img src="/content/blog/the-panda-cometh/makerbot.jpg" class="pulled-left" width="130px" height="100px"><p>We here at Caffeinated Panda Creations are the proud owners of a <a href="http://store.makerbot.com/replicator2.html" target="_new">Makerbot Replicator 2</a> 3D printer.</p><p>As well as using it for our creations we can also offer a bespoke printing service. Design your own objects or let us work with you to create and realise your vision in high quality PLA plastic.</p>
</div>
</div>
<div class="clearfix col-2">
<div class="column">
<h2>Emporia</h2>
<img src="/content/blog/the-panda-cometh/etsy.jpg" class="pulled-left" width="130px" height="100px"><p>Over the next few months we'll be opening our online stores where we'll be selling some of our premade and customisable pieces along with t-shirts and other apparel.</p>
</div>
<div class="column">
<h2>Costuming</h2>
<img src="/content/blog/the-panda-cometh/mask.jpg" class="pulled-left" width="130px" height="100px"><p>The panda team are keen costumers and going forward will be working on several exciting cosplaying projects for ourselves and others.</p><p>We'll also be keeping you up to date on where we'll be appearing and giving details on how we can work with you on your own costuming projects.</p>
</div>
</div>
EOT
;

		my $formatter = PML::HTMLFormatter->new();
		my $html = $formatter->format( $input_pml );
		is( $html, $expected_html, 'HTML as expected' );

	};
	return;
}


