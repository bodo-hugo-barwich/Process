use ExtUtils::MakeMaker;
 


WriteMakefile(
    NAME             => 'Process::SubProcess',
    LICENSE          => 'perl',
    AUTHOR           => 'Bodo (Hugo) Barwich <b.barwich@hotmail.com>',
    VERSION_FROM     => 'lib/Process/SubProcess.pm',
    MIN_PERL_VERSION => '5.10',
    test             => {TESTS => 't/*.t'},
    META_MERGE          => {
        resources       => {
            repository  => "https://github.com/bodo-hugo-barwich/Process",
        },
    },
);

