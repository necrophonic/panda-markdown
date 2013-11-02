use v5.10;

use strict;
use warnings;
use boolean;

use Test::More;
use Test::Exception;

use PML;

use_ok "PML";

	can_ok( 'PML', 'markdown' );

	lives_and { is PML::_type_to_tag('HEAD1'), 'h1' } 'HEAD1 maps to h1 ok';
	lives_and { is PML::_type_to_tag('HEAD2'), 'h2' } 'HEAD2 maps to h2 ok';
	lives_and { is PML::_type_to_tag('HEAD3'), 'h3' } 'HEAD3 maps to h3 ok';
	lives_and { is PML::_type_to_tag('HEAD4'), 'h4' } 'HEAD4 maps to h4 ok';
	lives_and { is PML::_type_to_tag('HEAD5'), 'h5' } 'HEAD5 maps to h5 ok';
	lives_and { is PML::_type_to_tag('HEAD6'), 'h6' } 'HEAD6 maps to h6 ok';

	lives_and { is PML::_type_to_tag('BLOCK'), 		'p' } 		'BLOCK maps to p ok';
	lives_and { is PML::_type_to_tag('STRONG'), 	'strong' } 	'STRONG maps to strong ok';
	lives_and { is PML::_type_to_tag('EMPHASIS'), 	'em' } 		'EMPHASIS maps to em ok';
	lives_and { is PML::_type_to_tag('UNDERLINE'), 	'u' } 		'UNDERLINE maps to u ok';

	lives_and { is PML::_type_to_tag('QUOTE'), 	'blockquote' } 	'QUOTE maps to blockquote ok';

	dies_ok { PML::_type_to_tag('INVALIDTAG') } 'Dies with invalid tag';


done_testing();
exit(0);
