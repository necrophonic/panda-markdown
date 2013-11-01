use v5.16;

use strict;
use warnings;

use Test::More;
use PML;

my $pml_with_html = 'This has some <html> in it & some display entities: &amp;';
my $expect 		  = 'This has some &lt;html&gt; in it &amp; some display entities: &amp;amp;'."\n";

is(PML::markdown($pml_with_html), $expect, 'Output HTML as expected');

done_testing();
exit(0);

# ------------------------------------------------------------------------------

