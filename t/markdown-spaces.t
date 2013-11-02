use v5.10;

use strict;
use warnings;

use Test::More;

use PML;

my $in;
my $expect;

# TEST 1
$in		= "This has  some   spaces     in        it\nand   newlines   with spaces.";
$expect = "<p>This has some spaces in it and newlines with spaces.</p>\n";
is(PML::markdown($in), $expect, 'Mixed spaces ok');

# TEST 2
$in		= '   Leading spaces';
$expect = "<p>Leading spaces</p>\n";
is(PML::markdown($in), $expect, 'Leading spaces ok');

# TEST 3
$in		= 'Trailing spaces    ';
$expect = "<p>Trailing spaces</p>\n";
is(PML::markdown($in), $expect, 'Trailing spaces ok');

done_testing();
exit(0);

# ------------------------------------------------------------------------------
