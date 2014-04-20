use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'WWW::Trello',
    AUTHOR           => q{Shane Utt <shaneutt@linux.com>},
    VERSION_FROM     => 'lib/WWW/Trello.pm',
    ABSTRACT_FROM    => 'lib/WWW/Trello.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
	'Want'                  => 0.23,
	'Test::Deep'            => 0.112,
        'Test::More'            => 1.001003,
	'URI'                   => 1.60,
	'LWP::UserAgent'        => 6.05,
	'HTTP::Request::Common' => 6.04,
    },
    PREREQ_PM => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'WWW-Trello-*' },
);
