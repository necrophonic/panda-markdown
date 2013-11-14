use v5.10;

use strict;
use warnings;
use boolean;

use Test::More;
use Test::Exception;

use_ok 'PML::ImageToken';

can_ok('PML::ImageToken','type');
can_ok('PML::ImageToken','src');
can_ok('PML::ImageToken','height');
can_ok('PML::ImageToken','width');
can_ok('PML::ImageToken','align');

my $token = new_ok 'PML::ImageToken';
is($token->type, 'IMAGE', 'Correct type [IMAGE]');

subtest "Default alignment" => sub {
	my $token = PML::ImageToken->new;
	is($token->align, '><', 'Default alignment centre if not set');

	$token->align('<<');
	is($token->align, '<<', 'Override default alignment');
};


done_testing();
