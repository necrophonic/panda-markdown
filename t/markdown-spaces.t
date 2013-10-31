use v5.16;

use strict;
use warnings;
use boolean;

use Test::More;
use Test::Exception;

use PML;

use_ok "PML";

my $in =<<EOT;
This has  some   spaces     in        it
and   newlines   with spaces.
EOT
;

my $expect = "This has some spaces in it and newlines with spaces.\n";

my $html = PML::markdown($in);


is($html, $expect, 'Output HTML as expected');


done_testing();
exit(0);

# ------------------------------------------------------------------------------
