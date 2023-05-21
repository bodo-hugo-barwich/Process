use ExtUtils::MakeMaker;
 


WriteMakefile(
    NAME             => 'Process::SubProcess',
    VERSION_FROM     => 'lib/Process/SubProcess.pm',
    MIN_PERL_VERSION => '5.010',
    test             => {TESTS => 't/*.t'},
    META_MERGE => {
        'meta-spec' => { version => 2 },
         resources => {
             repository => {
                 type => 'git',
                 url  => 'https://github.com/bodo-hugo-barwich/Process.git',
                 web  => 'https://github.com/bodo-hugo-barwich/Process',
             },
             bugtracker => {
                 web => 'https://github.com/bodo-hugo-barwich/Process/issues'
             },
         },
    },
);

