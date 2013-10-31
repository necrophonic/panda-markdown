use 5.010001;

use strict;
use warnings;

use Config;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME		=> 'Panda_Markdown',
	VERSION_FROM	=> 'lib/PML.pm',
	ABSTRACT	=> 'Blog orientated markdown',
	AUTHOR		=> 'J Gregory <john@johngregory.me.uk>',
	LICENSE		=> 'artistic_2',
	PREREQ_PM	=> {},
	TEST_REQUIRES => {
		"Test::More" => '0.99'
	},
	test 			=> {
		TESTS	=> 't/*.t'
	}
);
