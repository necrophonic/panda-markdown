use v5.10;

use strict;
use warnings;

use Test::More;
use PML;

my $in =<<EOT;
##Heading1##

###Heading2###

####Heading3####
EOT
;

my $expect = "<p><h1>Heading1</h1> <h2>Heading2</h2> <h3>Heading3</h3> </p>\n";
is(PML::markdown($in), $expect, 'Output HTML as expected');

done_testing();
exit(0);

# ------------------------------------------------------------------------------
