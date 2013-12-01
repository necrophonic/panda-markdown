#!/usr/bin/env perl

use strict;

use Test::More;
use Test::Exception;


use Readonly;
Readonly my $CLASS => 'PML::PullParser';

use_ok $CLASS;

use Log::Log4perl qw(:easy);
#Log::Log4perl->easy_init($OFF);


my $parser = undef;

subtest "Instantiation" => sub {

	throws_ok { $CLASS->new() }
		qr/Must supply 'pml' to PML::PullParser/,
		'new() dies with no pml supplied';

	lives_ok { $parser = new_ok $CLASS, ['pml'=>'Some PML'] }
		'new() lives ok with args supplied';

	is( scalar @{$parser->pml_chars}, 8,'Input PML split into 8 chars');
};


subtest "Internal methods" => sub {

	subtest "_create_token" => sub {
		throws_ok { $parser->_create_token() }
			qr/Encountered parse error \[No token data passed to _create_token\(\)\]/,
			'_create_token() dies when no token data passed';

		# No previous token
		$parser->temporary_token(undef);
		$parser->_create_token({type=>'STRING'});
		is($parser->token, undef, 'No previous token');
		is_deeply($parser->temporary_token,{type=>'STRING'}, 'New token created');

		# Now have previous token
		$parser->_create_token({type=>'LINK'});		
		is_deeply($parser->token, {type=>'STRING'}, 'Emit previous token' );
		is_deeply($parser->temporary_token,{type=>'LINK'}, 'New token created');		
	};

	# -------------------------------------------

	subtest "_append_to_string_token" => sub {
		# No previous string char
		$parser->token(undef);
		$parser->temporary_token(undef);
		$parser->_append_to_string_token('x');
		is_deeply(
			$parser->temporary_token,
			{type=>'STRING',content=>'x'},
			'No previous - set to new string token'
		);

		# Has previous string char
		$parser->_append_to_string_token('y');
		is_deeply(
			$parser->temporary_token,
			{type=>'STRING',content=>'xy'},
			'Appends to previous existing'
		);
		is($parser->token, undef, 'No token output');

		# Has previous
		$parser->temporary_token( {type=>'LINK'} );
		$parser->_append_to_string_token('x');
		is_deeply(
			$parser->temporary_token,
			{type=>'STRING',content=>'x'},
			'Create new token'
		);
		is_deeply($parser->token,{type=>'LINK'},'Get previous token');
	};

};


can_ok( $parser, qw|get_all_tokens get_next_token|);

done_testing();
