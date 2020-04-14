#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2020-03-21
# @package Test for the SubProcess Module
# @subpackage run_test_subprocess.pl

# This Module runs tests on the SubProcess Module
#
#---------------------------------
# Requirements:
# - The Perl Module "SubProcess" must be installed
#



use warnings;
use strict;

use Cwd qw(abs_path);

use Test::More;

BEGIN
{
  use lib "lib";
  use lib "../lib";
}  #BEGIN

require_ok('Process::SubProcess');

use Process::SubProcess qw(runSubProcess);



my $smodule = "";
my $spath = abs_path($0);


($smodule = $spath) =~ s/.*\/([^\/]+)$/$1/;
$spath =~ s/^(.*\/)$smodule$/$1/;


my $stestscript = "test_subprocess.pl";
my $iscriptpause = 3;

my $rscriptlog = undef;
my $rscripterror = undef;
my $iscriptstatus = -1;


print "Test: 'STDOUT , STDERR and EXIT CODE' do ...\n";


($rscriptlog, $rscripterror, $iscriptstatus)
  = runSubProcess("${spath}${stestscript} $iscriptpause");

isnt($rscriptlog, undef, "STDOUT Ref is returned");

isnt($rscripterror, undef, "STDERR Ref is returned");

isnt($iscriptstatus, undef, "EXIT CODE is returned");

ok($iscriptstatus =~ qr/^-?\d$/, "EXIT CODE is numeric");

print("EXIT CODE: '$iscriptstatus'\n");

if(defined $rscriptlog)
{
  isnt($$rscriptlog, '', "STDOUT was captured");

  print("STDOUT: '$$rscriptlog'\n");
} #if(defined $rscriptlog)

if(defined $rscripterror)
{
  isnt($$rscripterror, '', "STDERR was captured");

  print("STDERR: '$$rscripterror'\n");
} #if(defined $rscripterror)

print "\n";

print "Test: 'Profiling' do ...\n";

($rscriptlog, $rscripterror, $iscriptstatus)
  = runSubProcess(('command' => $spath . $stestscript, 'profiling' => 1));

print("EXIT CODE: '$iscriptstatus'\n");

if(defined $rscriptlog)
{
  print("STDOUT: '$$rscriptlog'\n");
}
else
{
  isnt($$rscriptlog, undef, "STDOUT was captured");
} #if(defined $rscriptlog)

if(defined $rscripterror)
{
  print("STDERR: '$$rscripterror'\n");
}
else
{
  isnt($$rscripterror, undef, "STDERR was captured");
} #if(defined $rscripterror)


done_testing();

