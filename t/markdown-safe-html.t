use v5.10;

use strict;
use warnings;

use Test::More;
use PML;

my $pml_with_html;
my $expect;

# TEST 1
$pml_with_html 	= 'This has some <html> in it & some display entities: &amp;';
$expect 		= 'This has some &lt;html&gt; in it &amp; some display entities: &amp;amp;'."\n";
is(PML::markdown($pml_with_html), $expect, 'Test #1 output HTML as expected (Basic)');

# TEST 2
$pml_with_html 	= 'Test some <html> across\n<p>several</p>\nlines & see what happens';
$expect 		= 'Test some &lt;html&gt; across\n&lt;p&gt;several&lt;/p&gt;\nlines &amp; see what happens'."\n";
is(PML::markdown($pml_with_html), $expect, 'Test #2 output HTML as expected (Multiline)');

# TEST 3
$pml_with_html	= 'Should escape <this> but not **these**';
$expect   		= 'Should escape &lt;this&gt; but not <strong>these</strong>'."\n";
is(PML::markdown($pml_with_html), $expect, 'Test #3 output HTML as expected (Don\'t escape generated tags)');

done_testing();
exit(0);

# ------------------------------------------------------------------------------

