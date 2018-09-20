#!/usr/bin/perl

=pod
# @author Bodo (Hugo) Barwich
# @version 2018-06-14
# @package Test for the Process::SubProcess Module
# @subpackage test_subprocess.pl

# This Module runs tests on the Process::SubProcess Module
#
#---------------------------------
# Requirements:
# - The Perl Module "Process::SubProcess" must be installed 
#
=cut



use Cwd qw(abs_path);


my $smodule = "";
my $spath = abs_path($0);

my $ipause = $1;


($smodule = $spath) =~ s/.*\/([^\/]+)$/$1/;
$spath =~ s/^(.*\/)$smodule$/;

$ipause = 0 unless(defined $ipause);


print STDERR "script '$smodule' START 0 ERROR\n";

print "script '$smodule' START 0\n";

print "script '$smodule' PAUSE '$ipause' ...\n";

sleep $ipause;

print "script '$smodule' END 1\n";

print STDERR "script '$smodule' END 1 ERROR\n";


