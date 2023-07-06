#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2023-07-05
# @package Process::SubProcess
# @subpackage scripts/find_version_commit.pl

# This Module parses the Git History to find the Merge Commit for the Version
#

use strict;
use warnings;

use Getopt::Long;
use Path::Tiny qw(path);
use JSON qw(encode_json);
use Data::Dump qw(dump);
use Git;

# ==============================================================================
# Auxiliary Functions

sub git_history {
    my ( $module_name, $maindir ) = @_;
    my %history_result = ( 'success' => 1, 'commits' => [] );

    my @log_lines  = ();
    my $commit     = undef;
    my $commit_idx = 0;

    eval {
        my $repo = Git->repository( Repository => $maindir . '/.git' );

        @log_lines = $repo->command( 'log', '-50' );
    };

    if ($@) {
        print STDERR
          "script '$module_name' - Git History: Git Log Command failed!\n";
        print STDERR
          "script '$module_name' - Git Log Exception Message: '$@'\n";

        @log_lines = ();

        $history_result{'success'} = 0;
    }

    $history_result{'success'} = 0 if ( scalar @log_lines == 0 );

    foreach my $line (@log_lines) {
        if ( $line =~ qr/^commit (.*)$/i ) {

            $commit = {
                'hash'       => $1,
                'hash_short' => substr( $1, 0, 7 ),
                'raw'        => $line . "\n",
                'index'      => $commit_idx
            };

            push @{ $history_result{'commits'} }, ($commit);

            $commit_idx++;
        }
        else {
            $commit->{'raw'} .= $line . "\n";

            if ( index( $line, ':' ) != -1 ) {
                if ( $line =~ qr/^([^:]+): (.*)/ ) {
                    $commit->{ lc $1 } = $2;
                }
            }
        }
    }

    foreach $commit ( @{ $history_result{'commits'} } ) {
        if ( defined $commit->{'author'} ) {
            if ( $commit->{'author'} =~ qr/^([^<]+) <([^>]+)>/ ) {
                $commit->{'author'} = { 'name' => $1, 'email' => $2 };
            }
        }

        if ( defined $commit->{'date'} ) {
            $commit->{'date'} =~ s/^\s+//;
        }
    }

    return \%history_result;
}

sub find_merge_commit {
    my ( $history, $commit ) = @_;

    my $commit_idx    = scalar($history) - 1;
    my $commit_search = undef;
    my $commit_merge  = undef;

    $commit_idx = $commit->{'index'} if ( defined $commit->{'index'} );

    while ( $commit_idx >= 0 && !defined $commit_merge ) {
        $commit_search = $history->[$commit_idx];

        if ( defined $commit_search->{'merge'} ) {
            $commit_merge = $commit_search;
        }
        else {
            $commit_idx--;
        }
    }

    return $commit_merge;
}

# ==============================================================================
# Executing Section

# ------------------------
# Script Environment

my $module_file = path($0)->basename;
my $path        = path($0)->parent->absolute;
my $maindir     = $path->parent;

# ------------------------
# Script Parameter

my @rqcommits     = ();
my $output_format = 'plain';
my $debug         = 0;
my $quiet         = 0;

my $ierr = 0;

GetOptions(
    'f|format=s' => \$output_format,
    'd|debug'    => \$debug,
    'q|quiet'    => \$quiet
);
@rqcommits = @ARGV;

@rqcommits =
  map { index( $_, '^' ) == 0 ? substr( $_, 1, length($_) ) : $_ } @rqcommits;
@rqcommits = map { length($_) > 7 ? substr( $_, 0, 7 ) : $_ } @rqcommits;

my %commits_res = ();

my $history_result = git_history( $module_file, $maindir->stringify );

my %history_commits = map { $_->{'hash_short'} => $_ }
  grep { defined $_->{'hash_short'} } @{ $history_result->{'commits'} };

if ($debug) {
    print "hist res dmp:\n", dump($history_result), "\n";
}

my $search = '';

foreach $search (@rqcommits) {
    $commits_res{$search} = 0;

    if ( defined $history_commits{$search} ) {
        $commits_res{$search} = {
            'origin' => $history_commits{$search},
            'merge'  => find_merge_commit(
                $history_result->{'commits'},
                $history_commits{$search}
            )
        };
    }
}

# ------------------------
# Print the Commit Result

if ( $output_format eq 'plain' ) {
    if ( scalar keys %commits_res > 0 ) {
        print "script '$module_file' - Version Commits:\n";

        foreach $search ( keys %commits_res ) {
            if ( ref $commits_res{$search} ne '' ) {
                if ( defined $commits_res{$search}->{'merge'} ) {
                    printf(
                        "%s/%s by '%s/%s'\n",
                        $commits_res{$search}->{'merge'}->{'hash_short'},
                        $commits_res{$search}->{'merge'}->{'hash'},
                        $commits_res{$search}->{'merge'}->{'author'}->{'name'},
                        $commits_res{$search}->{'merge'}->{'author'}->{'email'}
                    );
                }
                else {
                    printf(
                        "%s/%s by '%s/%s'\n",
                        $search,
                        $commits_res{$search}->{'origin'}->{'hash'},
                        $commits_res{$search}->{'origin'}->{'author'}->{'name'},
                        $commits_res{$search}->{'origin'}->{'author'}->{'email'}
                    );
                }
            }
            else {
                print $search, " - no entry found\n";

                $ierr = 1;
            }
        }
    }

}
elsif ( $output_format eq 'json' ) {
    print encode_json( \%commits_res );
}
else {
    print "script '$module_file' - Version Commits:\n", dump( \%commits_res ),
      "\n";
}

if ($debug) {
    print "script '$module_file': Script finished with [$ierr]\n";
}

exit $ierr;
