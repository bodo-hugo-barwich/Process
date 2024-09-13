requires 'Getopt::Long::Descriptive';
requires 'Path::Tiny';
requires 'JSON';
requires 'YAML';
requires 'Data::Dump';

on 'test' => sub {
  requires 'Test::More';
  requires 'Capture::Tiny';
};

feature 'test_perl-versions', 'Testing against different Perl Versions' => sub {
  requires 'local::lib';
  requires 'Perl::Build';
};
