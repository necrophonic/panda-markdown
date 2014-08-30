#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;

use Test::More;
use lib 't/lib';
use Helpers;

plan tests => 3;

	use_ok 'Text::CaffeinatedMarkup::HTML';
	new_ok 'Text::CaffeinatedMarkup::HTML';

	local $/=undef;	
	test_html_data_document(Text::CaffeinatedMarkup::HTML->new,<DATA>);

done_testing();


__DATA__
Yup, we're here! Caffeinated Panda Creations has launched the first phase of our new website.

Right now as you can see the blog is up and running and we'll be using it to keep you up to date with projects, events we're involved with, and new features coming to the site. Of course we'll still be streaming updates and content on [[http://facebook.com/caffeinatedpandacreations|facebook]] and [[http://twitter.com/cafpanda|twitter]] as well so come and join us there too!

As time goes on we'll be adding new sections to the website so stay tuned for updates. Upcoming soon will be more details on our creations and services, so here's some things to whet your appetite!
===========
## Custom Cyberfalls
{{cyberfalls.jpg|<<,H100,W130}}Cyberfalls for all your cybergoth and dance needs, at Caffeinated Panda Creations we specialise in custom designs and sets with [[https://www.google.co.uk/search?q=el+wire&safe=off&tbm=isch|EL-wire]] installations.

Whether you're looking for a themed set for a special occassion or straight forward cyber-chic, get in touch and we'll be happy to work with you!
-----------
## 3D Printing
{{makerbot.jpg|<<,H100,W130}}We here at Caffeinated Panda Creations are the proud owners of a [[http://store.makerbot.com/replicator2.html|Makerbot Replicator 2]] 3D printer.

As well as using it for our creations we can also offer a bespoke printing service. Design your own objects or let us work with you to create and realise your vision in high quality PLA plastic.
===========
===========
## Emporia
{{etsy.jpg|<<,H100,W130}}Over the next few months we'll be opening our online stores where we'll be selling some of our premade and customisable pieces along with t-shirts and other apparel.
-----------
## Costuming
{{mask.jpg|<<,H100,W130}}The panda team are keen costumers and going forward will be working on several exciting cosplaying projects for ourselves and others.

We'll also be keeping you up to date on where we'll be appearing and giving details on how we can work with you on your own costuming projects.
===========
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
<p>Yup, we're here! Caffeinated Panda Creations has launched the first phase of our new website.</p><p>Right now as you can see the blog is up and running and we'll be using it to keep you up to date with projects, events we're involved with, and new features coming to the site. Of course we'll still be streaming updates and content on <a href="http://facebook.com/caffeinatedpandacreations">facebook</a> and <a href="http://twitter.com/cafpanda">twitter</a> as well so come and join us there too!</p><p>As time goes on we'll be adding new sections to the website so stay tuned for updates. Upcoming soon will be more details on our creations and services, so here's some things to whet your appetite!</p><div class="clearfix cml-row cml-row-2"><span><h2>Custom Cyberfalls</h2><img src="cyberfalls.jpg" width="130" height="100" class="cml-pulled-left"><p>Cyberfalls for all your cybergoth and dance needs, at Caffeinated Panda Creations we specialise in custom designs and sets with <a href="https://www.google.co.uk/search?q=el+wire&safe=off&tbm=isch">EL-wire</a> installations.</p><p>Whether you're looking for a themed set for a special occassion or straight forward cyber-chic, get in touch and we'll be happy to work with you!</p></span><span><h2>3D Printing</h2><img src="makerbot.jpg" width="130" height="100" class="cml-pulled-left"><p>We here at Caffeinated Panda Creations are the proud owners of a <a href="http://store.makerbot.com/replicator2.html">Makerbot Replicator 2</a> 3D printer.</p><p>As well as using it for our creations we can also offer a bespoke printing service. Design your own objects or let us work with you to create and realise your vision in high quality PLA plastic.</p></span></div><div class="clearfix cml-row cml-row-2"><span><h2>Emporia</h2><img src="etsy.jpg" width="130" height="100" class="cml-pulled-left"><p>Over the next few months we'll be opening our online stores where we'll be selling some of our premade and customisable pieces along with t-shirts and other apparel.</p></span><span><h2>Costuming</h2><img src="mask.jpg" width="130" height="100" class="cml-pulled-left"><p>The panda team are keen costumers and going forward will be working on several exciting cosplaying projects for ourselves and others.</p><p>We'll also be keeping you up to date on where we'll be appearing and giving details on how we can work with you on your own costuming projects.</p></span></div>