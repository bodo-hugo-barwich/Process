#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2020-03-21
# @package Test for the Process::SubProcess Module
# @subpackage test_subprocess.pl

# This Script is the Test Script which is run in the Process::SubProcess Module Test
# It generates Output to STDOUT and STDERR
# It returns the EXIT CODE passed as Parameter. Only Integer EXIT CODES are allowed
#
#---------------------------------
# Requirements:
#



use warnings;
use strict;

use Cwd qw(abs_path);



my $smodule = "";
my $spath = abs_path($ARGV[0]);

my $ipause = $ARGV[1];
my $ierr = $ARGV[2];


($smodule = $spath) =~ s/.*\/([^\/]+)$/$1/;
$spath =~ s/^(.*\/)$smodule$/$1/;

$ipause = 0 unless(defined $ipause);

if(defined $ierr)
{
  $ierr = 1 unless($ierr =~ qr/^-?\d$/);
}
else
{
  $ierr = 0;
}

print STDERR "script '$smodule' START 0 ERROR\n";

print "script '$smodule' START 0\n";

print "script '$smodule' PAUSE '$ipause' ...\n";

sleep $ipause;

print "script '$smodule' END 1\n";

print STDERR "script '$smodule' END 1 ERROR\n";


exit $ierr;
