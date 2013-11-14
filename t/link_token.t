use v5.10;

use strict;
use warnings;
use boolean;

use Test::More;
use Test::Exception;

use_ok 'PML::LinkToken';

can_ok('PML::LinkToken','type');
can_ok('PML::LinkToken','text');
can_ok('PML::LinkToken','url');

my $token = new_ok 'PML::LinkToken';
is($token->type, 'LINK', 'Correct type [LINK]');


subtest "Text builder" => sub {
	my $token = PML::LinkToken->new( url => 'http://www.test.com/' );
	is($token->text, 'http://www.test.com/', 'Text default to url when not set');

	$token->text('Some text');
	is($token->text, 'Some text', 'Text manually set');
};

done_testing();
