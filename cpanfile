requires 'Data::Dump';

on 'test' => sub {
  requires 'Test::More';
  requires 'Capture::Tiny';
};

feature 'test_5.10', 'testing in perl 5.10' => sub { 
  requires 'Perl::Build';
};
