use 5.010001;

use strict;
use warnings;

use Config;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME		=> 'Text::CaffeinatedMarkup',
	VERSION		=> '0.20',
	ABSTRACT	=> 'Panda blog orientated markup',
	AUTHOR		=> 'J Gregory <jgregory@cpan.org>',
	LICENSE		=> 'artistic_2',
	PREREQ_PM	=> {
		'Moo'	   	   => '1.003001',
		'boolean'  	   => '0.30',
		'Readonly' 	   => '1.03',
		'HTML::Escape' => '1.08',
		'Log::Log4perl'=> '1.42',
		'Log::Declare' => '0.03'
	},
	BUILD_REQUIRES => {
		"Test::More" 	  => '0.99',
		"Test::Exception" => '0.32'
	},
	test  => { TESTS    => 't/*.t t/*/*.t' },	
	META_MERGE	=> {
		requires  => {perl => '5.010001'},
		resources => {
			homepage	=> 'http://necrophonic.github.io/text-caffeinatedmarkup',
			license     => 'http://www.opensource.org/licenses/artistic-license-2.0',
			repository	=> 'http://github.com/necrophonic/text-caffeinatedmarkup',
			bugtracker	=> 'http://github.com/necrophonic/text-caffeinatedmarkup/issues'
		},
		no_index => {directory => ['t']}
	},
	dist => { COMPRESS => "gzip -9", SUFFIX => "gz" },
);
