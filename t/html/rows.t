#!/usr/bin/env perl
use strict;
use v5.10;

use Log::Declare;
use Test::More;
use Text::CaffeinatedMarkup::HTML;

plan tests => 1;

	my $parser = Text::CaffeinatedMarkup::HTML->new;

	test_basic_row();

done_testing();

# ------------------------------------------------------------------------------

sub test_basic_row {
    subtest 'Basic row' => sub {
        plan tests => 4;
        is $parser->do(qq|==\nFirst\n--\nSecond\n==|),
           q|<div class="clearfix row-2"><span class="column"><p>First</p></span><span class="column"><p>Second</p></span></div>|,
           'two column row';

        is $parser->do(qq|==\nFirst\n--\n**Second**\n==|),
           q|<div class="clearfix row-2"><span class="column"><p>First</p></span><span class="column"><p><strong>Second</strong></p></span></div>|,
           'two column row with emphasis';

        is $parser->do(qq|==\nFirst\n--\n{{image.jpg}}\n==|),
           q|<div class="clearfix row-2"><span class="column"><p>First</p></span><span class="column"><img src="image.jpg"></span></div>|,
           'two column row with image';

        is $parser->do(qq|First\n==\nThen a row\n==|),
           q|<p>First</p><div class="clearfix row-1"><span class="column"><p>Then a row</p></span></div>|,
           'text before a row';
    };
}

# ------------------------------------------------------------------------------