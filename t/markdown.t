use v5.16;

use strict;
use warnings;
use boolean;

use Test::More;
use Test::Exception;

use PML;

use_ok "PML";

my $in =<<EOT;
##Heading1##

###Heading2###

####Heading3####
EOT
;

my $expect = "<h1>Heading1</h1> <h2>Heading2</h2> <h3>Heading3</h3>\n";

my $html = PML::markdown($in);

is($html, $expect, 'Output HTML as expected');


done_testing();
exit(0);

# ------------------------------------------------------------------------------
