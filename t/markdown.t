use v5.16;

use strict;
use warnings;

use Test::More;
use PML;

use_ok "PML";

can_ok("PML","markdown");

my $in =<<EOT;
##Heading1##

###Heading2###

####Heading3####
EOT
;

my $expect = "<h1>Heading1</h1> <h2>Heading2</h2> <h3>Heading3</h3>\n";
is(PML::markdown($in), $expect, 'Output HTML as expected');

done_testing();
exit(0);

# ------------------------------------------------------------------------------
