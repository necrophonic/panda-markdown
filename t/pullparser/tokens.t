#!/usr/bin/perl
use strict;

use Test::More;
plan tests => 16;


my $PACKAGE_ROOT = "Text::CaffeinatedMarkup::PullParser::";

use_ok $PACKAGE_ROOT."TextToken";
new_ok $PACKAGE_ROOT."TextToken";
isa_ok $PACKAGE_ROOT."TextToken", $PACKAGE_ROOT."BaseToken";
can_ok $PACKAGE_ROOT."TextToken", qw|append_content|;

use_ok $PACKAGE_ROOT."BlockQuoteToken";
new_ok $PACKAGE_ROOT."BlockQuoteToken";
isa_ok $PACKAGE_ROOT."BlockQuoteToken", $PACKAGE_ROOT."BaseToken";

use_ok $PACKAGE_ROOT."ColumnDividerToken";
new_ok $PACKAGE_ROOT."ColumnDividerToken";
isa_ok $PACKAGE_ROOT."ColumnDividerToken", $PACKAGE_ROOT."BaseToken";

use_ok $PACKAGE_ROOT."DividerToken";
new_ok $PACKAGE_ROOT."DividerToken";
isa_ok $PACKAGE_ROOT."DividerToken", $PACKAGE_ROOT."BaseToken";

use_ok $PACKAGE_ROOT."EmphasisToken";
new_ok $PACKAGE_ROOT."EmphasisToken";
isa_ok $PACKAGE_ROOT."EmphasisToken", $PACKAGE_ROOT."BaseToken";


done_testing();
