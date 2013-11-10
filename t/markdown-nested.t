use v5.10;

use strict;
use warnings;
use boolean;

use Test::More;
use Test::Exception;

use PML;

use_ok "PML";

my $in =<<EOT;
This has some **bold** and some //italic//
and some //**bold italic**//
EOT
;

my $expect = qq|<p>This has some <strong>bold</strong> and some <em>italic</em><br>and some <em><strong>bold italic</strong></em></p>\n|;

my $html = PML::markdown($in);

is($html, $expect, 'Output HTML as expected');


done_testing();
exit(0);

# ------------------------------------------------------------------------------
