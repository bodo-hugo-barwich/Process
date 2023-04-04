use ExtUtils::MakeMaker;
 


WriteMakefile(
    NAME             => 'Process::SubProcess',
    VERSION_FROM     => 'lib/Process/SubProcess.pm',
    MIN_PERL_VERSION => '5.010',
    test             => {TESTS => 't/*.t'}
);

