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
{{meshlab.jpg|>>}}Here at the Panda we love our [[http://makerbot.com|makerbot]], but 3D printing is far from an exact science...

Recently we've been working on a piece for an //Aliens// [[http://www.imdb.com/title/tt0090605/|Colonial Marine]] cosplay and it's certainly tested our skills! The design files were supplied to us by our customer and on the surface it's a fairly simple piece - a box that holds the batteries for shoulder mounted lamp - but there's been much more to it than meets the eye. Settle in for the story so far!

To begin with, the piece is bigger than anything we've attempted in the printer thus far, measuring around 160x105x70mm. This isn't near the largest build size the Replicator can work with but certainly limits options for orientation on the build plate. Notwithstanding the fact that the main part takes on average around //12 hours// to print, an object of any real size in a 3D printer tends to suffer from //warping// and //cracking//.

## Ahead warp factor 5!
When a 3D model is printed and begins to cool, it starts to contract. This isn't too much of an issue with a small piece as the relative contraction is fairly small and with the piece being finished quickly the cooling is fairly uniform. With a larger piece however cooling can be much more inconsistent. This tends to mean that as each layer cools upon an already cool layer below it starts to pull against it much like a rubber band stretched across a ruler (or strings on a guitar neck for the musically inclined!) causing a //bow// like effect and lifting at the edges or causing middle layers to crack off from those underneath.

{{ears.jpg|<<}}Our early test prints suffered heavily from warping, but after we trawled the knowledge of the interwebs and did some experimentation we came a solution involving several things: attempting to ensure the consistency of the ambient room temperature over the full course of the print; being //very// pedantic with the [[http://www.makerbot.com|makerbot]] build plate calibration; and retro-fitting the model in [[http://en.wikipedia.org/wiki/Computer-aided_design|CAD]] software with \"mouse ears\".

Not literal mouse ears of course, but rather extra circular pieces attached to the corners of the model to help keep it attached to the build plate and counter the pull caused by cooling. This relatively simple thing (along with keen watching of the first couple of layers to ensure the plastic bonds to the build plate) has led to a massively more consistent set of prints and, as each \"ear\" is only 0.3-0.4mm thick they're easy to clean off the finished model with a craft knife (**remember kids**: knives are sharp and you can hurt yourself. Honestly I didn't forget that for a moment and slice my finger. Not all all *//ahem//*)

## Cliffhanger!
//Warping// and //cracking// were far from the only challenges we faced. Possibly the biggest was exactly //how to orient// the box for printing. A 3D printer (of the [[http://www.makerbot.com|makerbot]] ilk) work by building up layer by layer - all very well and good if you want to print a scale model of the pyramids, but what if you want to print a bridge? What about all those parts that are //in the air//? Those //overhangs// are a problem for 3D printing because, of course, you can't balance molten plastic on air!

The printer can automatically produce supports for these overhangs but can be a little imprecise and hard to clean off the model afterwards so keeping them to a minimum was a must!

{{printed.jpg|>>}}To address this we've re-chunked the original model into sectional parts that can be separately printed, minimising size and overhangs, and then reassembled to make the finished piece. We've also added our own supports to the model in place of automatic ones so that we have more control over what's produced and how easy they are to remove cleanly.

## Results so far and the next steps
Currently the main part of the box and the back/base are done and looking pretty fine! Next up is the lid and that has it's own challenges.

The current 3D model is proving tricky to //slice// (prep for printing) due to the shear number of [[http://en.wikipedia.org/wiki/Polygon_mesh|polygon faces]] in the 3D file. But hey, that's just another challenge and another opportunity to learn new tricks!

We've certainly learnt a lot already in this build and it'll stand us in good sted for others going forward. Most of all, it's been fun so far :)

//Got an idea for a 3D print or have a pre-designed to produce? Get in touch with us and we'll be happy to discuss it with you and see if we can help!//
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
<img src="meshlab.jpg" class="pull-right"><p>Here at the Panda we love our <a href="http://makerbot.com">makerbot</a>, but 3D printing is far from an exact science...</p><p>Recently we've been working on a piece for an <em>Aliens</em> <a href="http://www.imdb.com/title/tt0090605/">Colonial Marine</a> cosplay and it's certainly tested our skills! The design files were supplied to us by our customer and on the surface it's a fairly simple piece - a box that holds the batteries for shoulder mounted lamp - but there's been much more to it than meets the eye. Settle in for the story so far!</p><p>To begin with, the piece is bigger than anything we've attempted in the printer thus far, measuring around 160x105x70mm. This isn't near the largest build size the Replicator can work with but certainly limits options for orientation on the build plate. Notwithstanding the fact that the main part takes on average around <em>12 hours</em> to print, an object of any real size in a 3D printer tends to suffer from <em>warping</em> and <em>cracking</em>.</p><h2>Ahead warp factor 5!</h2><p>When a 3D model is printed and begins to cool, it starts to contract. This isn't too much of an issue with a small piece as the relative contraction is fairly small and with the piece being finished quickly the cooling is fairly uniform. With a larger piece however cooling can be much more inconsistent. This tends to mean that as each layer cools upon an already cool layer below it starts to pull against it much like a rubber band stretched across a ruler (or strings on a guitar neck for the musically inclined!) causing a <em>bow</em> like effect and lifting at the edges or causing middle layers to crack off from those underneath.</p><img src="ears.jpg" class="pull-left"><p>Our early test prints suffered heavily from warping, but after we trawled the knowledge of the interwebs and did some experimentation we came a solution involving several things: attempting to ensure the consistency of the ambient room temperature over the full course of the print; being <em>very</em> pedantic with the <a href="http://www.makerbot.com">makerbot</a> build plate calibration; and retro-fitting the model in <a href="http://en.wikipedia.org/wiki/Computer-aided_design">CAD</a> software with "mouse ears".</p><p>Not literal mouse ears of course, but rather extra circular pieces attached to the corners of the model to help keep it attached to the build plate and counter the pull caused by cooling. This relatively simple thing (along with keen watching of the first couple of layers to ensure the plastic bonds to the build plate) has led to a massively more consistent set of prints and, as each "ear" is only 0.3-0.4mm thick they're easy to clean off the finished model with a craft knife (<strong>remember kids</strong>: knives are sharp and you can hurt yourself. Honestly I didn't forget that for a moment and slice my finger. Not all all *<em>ahem</em>*)</p><h2>Cliffhanger!</h2><p><em>Warping</em> and <em>cracking</em> were far from the only challenges we faced. Possibly the biggest was exactly <em>how to orient</em> the box for printing. A 3D printer (of the <a href="http://www.makerbot.com">makerbot</a> ilk) work by building up layer by layer - all very well and good if you want to print a scale model of the pyramids, but what if you want to print a bridge? What about all those parts that are <em>in the air</em>? Those <em>overhangs</em> are a problem for 3D printing because, of course, you can't balance molten plastic on air!</p><p>The printer can automatically produce supports for these overhangs but can be a little imprecise and hard to clean off the model afterwards so keeping them to a minimum was a must!</p><img src="printed.jpg" class="pull-right"><p>To address this we've re-chunked the original model into sectional parts that can be separately printed, minimising size and overhangs, and then reassembled to make the finished piece. We've also added our own supports to the model in place of automatic ones so that we have more control over what's produced and how easy they are to remove cleanly.</p><h2>Results so far and the next steps</h2><p>Currently the main part of the box and the back/base are done and looking pretty fine! Next up is the lid and that has it's own challenges.</p><p>The current 3D model is proving tricky to <em>slice</em> (prep for printing) due to the shear number of <a href="http://en.wikipedia.org/wiki/Polygon_mesh">polygon faces</a> in the 3D file. But hey, that's just another challenge and another opportunity to learn new tricks!</p><p>We've certainly learnt a lot already in this build and it'll stand us in good sted for others going forward. Most of all, it's been fun so far :)</p><p><em>Got an idea for a 3D print or have a pre-designed to produce? Get in touch with us and we'll be happy to discuss it with you and see if we can help!</em></p>