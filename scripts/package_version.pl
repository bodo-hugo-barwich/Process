#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2023-06-27
# @package Process::SubProcess
# @subpackage scripts/package_version.pl

# This Module finds the Package Version and the file where it is defined
#

use warnings;
use strict;

use Getopt::Long;
use Path::Tiny qw(path);
use JSON qw(encode_json);
use Data::Dump qw(dump);
use Git;

# ==============================================================================
# Auxiliary Functions

sub git_blame_version_file {
    my ( $module_name, $maindir, $version, $debug, $quiet ) = @_;

    my @blame_lines = ();

    eval {
        my $repo = Git->repository( Repository => $maindir . '/.git' );

        @blame_lines = $repo->command( 'blame', $version->{version_file} );
    };

    if ($@) {
        print STDERR "script '$module_name' - Version File '"
          . $version->{version_file}
          . "': Git Blame Command failed!\n";
        print STDERR
          "script '$module_name' - Git Blame Exception Message: '$@'\n";

        @blame_lines = ();

        $version->{'success'} = 0;
    }

    print "blm dmp:\n", dump( \@blame_lines ), "\n"
      if ( $debug > 0 && $quiet < 1 );

    foreach (@blame_lines) {
        if ( $_ =~ m#^(([^\(]+) (\([^\)]+\))\s+$version->{version_search})# ) {
            $version->{version_commit_raw} = [ $2, $3, $1 ];
        }
    }

    if ( defined $version->{version_commit_raw} ) {

        print "cmt raw: '" . $version->{version_commit_raw}[0] . "'\n"
          if ( $debug > 0 && $quiet < 1 );

        $version->{version_commit} =
          ( split( ' ', $version->{version_commit_raw}[0] ) )[0];

        $version->{'success'} = 1;
    }
    else {
        $version->{version_commit} = '';
        $version->{'success'}      = 0;
    }

}

# ==============================================================================
# Executing Section

my $output_format = 'plain';
my $debug         = 0;
my $quiet         = 0;

my $ierr = 0;

GetOptions(
    'f|format=s' => \$output_format,
    'd|debug'    => \$debug,
    'q|quiet'    => \$quiet
);

my $module_file = path($0)->basename;
my $path        = path($0)->parent->absolute;
my $maindir     = $path->parent;

my %version = ();

if ($debug) {
    print "md: '$module_file'; pth: '"
      . $path->stringify
      . "'; mn dir: '"
      . $maindir->stringify . "'\n";
}

#Disable Warning Message Translation
$ENV{'LANGUAGE'} = 'C';

if ( $maindir->child('Makefile.PL')->exists ) {
    my $makefile        = $maindir->child('Makefile.PL');
    my $packagesettings = $makefile->slurp;

    if ($debug) {
        print "file 'Makefile.PL': settings:\n'$packagesettings'\n";
    }

    if ( $packagesettings =~ qr/^\s*name\s*=>\s*['"]([^'"]*)['"]/mi ) {
        $version{name} = $1;
    }
    else {
        print "name miss\n" if ($debug);
    }

    if ( $packagesettings =~ qr/^\s*(version\s*=>\s+['"]([^'"]*)['"])/mi ) {
        $version{version}        = $2;
        $version{version_search} = $1;
        $version{version_file}   = 'Makefile.PL';
    }

    if ( $packagesettings =~ qr/^\s*version_from\s*=>\s+['"]([^'"]*)['"]/mi ) {
        $version{version_file} = $1;
    }

}
else {
    print STDERR "file 'Makefile.PL': file is not found!\n" unless ($quiet);

    $ierr = 2;
}

if ($debug) {
    print "ver 1 dmp:\n", dump( \%version ), "\n";
}

unless ( defined $version{version} ) {
    if ( defined $version{version_file} ) {
        my $versionfile = $maindir->child( $version{version_file} );

        if ( $versionfile->exists ) {
            my $filecontent = $versionfile->slurp;

            if ( $filecontent =~
                qr/^\s*(our\s+\$version\s*=\s+['"]([^'"]*)['"])/mi )
            {
                $version{version}        = $2;
                $version{version_search} = $1;

                $version{version_search} =~ s#\$#\[\$\]#;
            }
            else {
                print "version miss\n" if ($debug);
            }

        }
        else {
            print STDERR
              "Version File '$version{version_file}': File does not exist\n"
              unless ($quiet);

            $ierr = 2;
        }
    }
}

if ($debug) {
    print "ver 2 dmp:\n", dump( \%version ), "\n";
}

if ( defined $version{version} && defined $version{version_file} ) {
    git_blame_version_file( $module_file, $maindir->stringify, \%version,
        $debug, $quiet );

    $ierr = 1 unless ( $version{'success'} );
}

if ($debug) {
    print "ver 3 dmp:\n", dump( \%version ), "\n";
}

# ------------------------
# Print the Version Result

if ( $output_format eq 'plain' ) {
    printf "%s@%s=%s@%s\n", $version{name}, $version{version_file},
      $version{version}, $version{version_commit};
}
elsif ( $output_format eq 'json' ) {
    print encode_json( \%version );
}
else {
    print "script '$module_file' - Version Commits:\n", dump( \%version ), "\n";
}

if ($debug) {
    print "script '$module_file': Script finished with [$ierr]\n";
}

exit $ierr;
