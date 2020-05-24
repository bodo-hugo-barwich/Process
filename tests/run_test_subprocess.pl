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

use Time::HiRes qw(gettimeofday);

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
my $itestpause = 3;
my $iteststatus = 4;

my $rscriptlog = undef;
my $rscripterror = undef;
my $iscriptstatus = -1;


#------------------------
#Test: 'runSubProcess() Function'

print "Test: 'runSubProcess() Function' do ...\n";

($rscriptlog, $rscripterror, $iscriptstatus)
  = runSubProcess("${spath}${stestscript} $itestpause $iteststatus");


isnt($rscriptlog, undef, "STDOUT Ref is returned");

isnt($rscripterror, undef, "STDERR Ref is returned");

isnt($iscriptstatus, undef, "EXIT CODE is returned");

ok($iscriptstatus =~ qr/^-?\d$/, "EXIT CODE is numeric");

is($iscriptstatus, $iteststatus, 'EXIT CODE is correct');

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


#------------------------
#Test: 'Profiling'

my $proctest = undef;

my $itm = -1;
my $itmstrt = -1;
my $itmend = -1;
my $itmexe = -1;


print "Test: 'Profiling' do ...\n";

$proctest = Process::SubProcess::->new(('command' => $spath . $stestscript
  , 'profiling' => 1));

is($proctest->isProfiling, 1, 'Profiling activated');

$itmstrt = gettimeofday();

print "script '$stestscript' Start - Time Now: '$itmstrt' s\n";

is($proctest->Run, 1, "script '$stestscript': Execution correct");

$itmend = gettimeofday();

$itm = ($itmend - $itmstrt) * 1000;

print "script '$stestscript' End - Time Now: '$itmend' s\n";

print "script '$stestscript' run in '$itm' ms\n";

$rscriptlog = $proctest->getReportString;
$rscripterror = $proctest->getErrorString;
$iscriptstatus = $proctest->getProcessStatus;

isnt($proctest->getExecutionTime, -1 , "Execution Time was measured");

print("Execution Time: '", $proctest->getExecutionTime, "'\n");

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

