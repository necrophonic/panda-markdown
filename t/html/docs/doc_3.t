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
Happy new year from us at the **Caffeinated Panda Creations** team! We hope that you and yours all had a great holiday season and new year shenanigans! So what does the new year hold for us at the panda?


{{set.jpg|>>}}
## More cyberfalls!
Having recently delivered a set of full-head cyberfalls to a happy customer we're hot onto creating some more custom sets!

Want a sneak peak? Well a few ideas currently residing on the drawing board include: a set of double tie-in falls inspired by Valve's Portal games; some retro steampunk leather and brass inspired falls; and some cute valentines falls. These are just a few we've got in the works but we're always happy to consider commissions.

There'll be more El wire fitted falls inbound too. We've got hold of some very funky \"chasing\" EL wire which is going to look pretty awesome in situ!

{{tags.jpg|<<}}
## More 3D printing!
You may already have seen the simple personalised gift tags that we produced for this last christmas. In the new year we'll be continuing to work on designs and techniques to see what other awesomeness we can print. And of course we'll be working on a 3D printed //Caffeinated Panda// model!

Of course if you're interested in having something designed and/or printed then feel free to get in touch and we'll be happy to work with you.

{{vac.jpg|>>}}
## More sucking!
[[http://en.wikipedia.org/wiki/Vacuum_forming|Vacform]] sucking that is :-) We've build a small scale vacformer which we're itching to get to use in anger once we can track a good reliable source of ABS plastic.

There are plans already in the works for some mini cosplay involving a cuddly friend from well known stuff-n-hug emporium which should be pretty cool! We'll post more details and plans as they evolve.

## More Website!
More sections are going to be coming to this site soon. These will be focusing on our cyberfalls and other creative projects to give you more idea of the things we do and the things we can do for you.

## More stuff to buy!
In the new year we'll be working to get our outlets up and running. These will be selling small pre-made creations, custom t-shirt designs and, well, whatever else our fevered imaginations create!

## More... well, more more!
Yup, there'll be more. Most of it we don't even know ourselves yet! Keep up to date on our [[https://www.facebook.com/caffeinatedpandacreations|facebook page]] and [[https://twitter.com/cafpanda|twitter feed]] as well as of course this blog for ongoing updates!

We always love to hear from you so get in touch on social media or email us at [[mailto:thepanda@caffeinatedpandacreations.co.uk|thepanda@caffeinatedpandacreations.co.uk]]!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
<p>Happy new year from us at the <strong class="cml-strong">Caffeinated Panda Creations</strong> team! We hope that you and yours all had a great holiday season and new year shenanigans! So what does the new year hold for us at the panda?</p><img class="cml-img cml-pulled-right" src="set.jpg"><h2>More cyberfalls!</h2><p>Having recently delivered a set of full-head cyberfalls to a happy customer we're hot onto creating some more custom sets!</p><p>Want a sneak peak? Well a few ideas currently residing on the drawing board include: a set of double tie-in falls inspired by Valve's Portal games; some retro steampunk leather and brass inspired falls; and some cute valentines falls. These are just a few we've got in the works but we're always happy to consider commissions.</p><p>There'll be more El wire fitted falls inbound too. We've got hold of some very funky "chasing" EL wire which is going to look pretty awesome in situ!</p><img class="cml-img cml-pulled-left" src="tags.jpg"><h2>More 3D printing!</h2><p>You may already have seen the simple personalised gift tags that we produced for this last christmas. In the new year we'll be continuing to work on designs and techniques to see what other awesomeness we can print. And of course we'll be working on a 3D printed <em class="cml-em">Caffeinated Panda</em> model!</p><p>Of course if you're interested in having something designed and/or printed then feel free to get in touch and we'll be happy to work with you.</p><img class="cml-img cml-pulled-right" src="vac.jpg"><h2>More sucking!</h2><p><a href="http://en.wikipedia.org/wiki/Vacuum_forming">Vacform</a> sucking that is :-) We've build a small scale vacformer which we're itching to get to use in anger once we can track a good reliable source of ABS plastic.</p><p>There are plans already in the works for some mini cosplay involving a cuddly friend from well known stuff-n-hug emporium which should be pretty cool! We'll post more details and plans as they evolve.</p><h2>More Website!</h2><p>More sections are going to be coming to this site soon. These will be focusing on our cyberfalls and other creative projects to give you more idea of the things we do and the things we can do for you.</p><h2>More stuff to buy!</h2><p>In the new year we'll be working to get our outlets up and running. These will be selling small pre-made creations, custom t-shirt designs and, well, whatever else our fevered imaginations create!</p><h2>More... well, more more!</h2><p>Yup, there'll be more. Most of it we don't even know ourselves yet! Keep up to date on our <a href="https://www.facebook.com/caffeinatedpandacreations">facebook page</a> and <a href="https://twitter.com/cafpanda">twitter feed</a> as well as of course this blog for ongoing updates!</p><p>We always love to hear from you so get in touch on social media or email us at <a href="mailto:thepanda@caffeinatedpandacreations.co.uk">thepanda@caffeinatedpandacreations.co.uk</a>!</p>