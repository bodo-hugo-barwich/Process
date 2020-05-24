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
#Test: 'Script not found'

my $proctest = undef;


print "Test: 'Script not found' do ...\n";

$proctest = Process::SubProcess::->new(('command' => $spath . 'no_script.sh'));

is($proctest->Run, 0, "script 'no_script.sh': Execution failed");

$rscriptlog = $proctest->getReportString;
$rscripterror = $proctest->getErrorString;
$iscriptstatus = $proctest->getProcessStatus;

is($proctest->getErrorCode, 1, "ERROR CODE '1' is correct");

is($iscriptstatus, 2, "EXIT CODE '2' is correct");

isnt($rscripterror, undef, "STDERR Ref is returned");

if(defined $rscripterror)
{
  ok($$rscripterror =~ qr/no such file/i, "STDERR has Not Found Error");

  print("STDERR: '$$rscripterror'\n");
} #if(defined $rscripterror)

print "\n";


#------------------------
#Test: 'No Permission'

print "Test: 'No Permission' do ...\n";


$proctest = Process::SubProcess::->new(('command' => $spath . 'noexec_script.pl'));

is($proctest->Run, 0, "script 'noexec_script.pl': Execution failed");

$rscriptlog = $proctest->getReportString;
$rscripterror = $proctest->getErrorString;
$iscriptstatus = $proctest->getProcessStatus;

is($proctest->getErrorCode, 1, "ERROR CODE '1' is correct");

is($iscriptstatus, 13, "EXIT CODE '13' is correct");

isnt($rscripterror, undef, "STDERR Ref is returned");

if(defined $rscripterror)
{
  ok($$rscripterror =~ qr/permission denied/i, "STDERR has No Permission Error");

  print("STDERR: '$$rscripterror'\n");
} #if(defined $rscripterror)

print "\n";


#------------------------
#Test: 'Sub Process Bash Error'

print "Test: 'Sub Process Bash Error' do ...\n";


$proctest = Process::SubProcess::->new(('command' => $spath . 'nobashbang_script.pl'));

is($proctest->Launch, 1, "script 'nobashbang_script.pl': Launch succeed");
is($proctest->Wait, 1, "script 'nobashbang_script.pl': Execution finished correctly");

$rscriptlog = $proctest->getReportString;
$rscripterror = $proctest->getErrorString;
$iscriptstatus = $proctest->getProcessStatus;

is($proctest->getErrorCode, 1, "ERROR CODE '1' is correct");

is($iscriptstatus, 2, "EXIT CODE '2' is correct");

isnt($rscripterror, undef, "STDERR Ref is returned");

if(defined $rscripterror)
{
  ok($$rscripterror =~ qr/syntax error/i, "STDERR has Bash Error");

  print("STDERR: '$$rscripterror'\n");
} #if(defined $rscripterror)

print "\n";


#------------------------
#Test: 'Sub Process Perl Exception'

print "Test: 'Sub Process Perl Exception' do ...\n";


$proctest = Process::SubProcess::->new(('command' => $spath . 'exception_script.pl'));

is($proctest->Launch, 1, "script 'exception_script.pl': Launch succeed");
is($proctest->Wait, 1, "script 'exception_script.pl': Execution finished correctly");

$rscriptlog = $proctest->getReportString;
$rscripterror = $proctest->getErrorString;
$iscriptstatus = $proctest->getProcessStatus;

is($proctest->getErrorCode, 1, "ERROR CODE '1' is correct");

is($iscriptstatus, 255, "EXIT CODE '255' is correct");

isnt($rscripterror, undef, "STDERR Ref is returned");

if(defined $rscripterror)
{
  ok($$rscripterror =~ qr/script died/i, "STDERR has Perl Exception");

  print("STDERR: '$$rscripterror'\n");
} #if(defined $rscripterror)

print "\n";


#------------------------
#Test: 'Profiling'

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

print "\n";


#------------------------
#Test: 'Read Timeout'

$proctest = undef;

$itestpause = 3;

$itm = -1;
$itmstrt = -1;
$itmend = -1;
$itmexe = -1;


print "Test: 'Read Timeout' do ...\n";

$proctest = Process::SubProcess::->new(('command' => $spath . $stestscript . ' ' . $itestpause
  , 'profiling' => 1));

$proctest->setReadTimeout(2);

is($proctest->getReadTimeout, 2, 'Read Timeout activated');

is($proctest->isProfiling, 0, 'Profiling deactivated');

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

is($proctest->getExecutionTime, -1 , "Execution Time was not measured");

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

print "\n";


done_testing();

