#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2020-09-06
# @package Test for the Process::SubProcess Module
# @subpackage test_subprocess.t

# This Module runs tests on the Process::SubProcess Module
#
#---------------------------------
# Requirements:
# - The Perl Module "Process::SubProcess" must be installed
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

#Disable Warning Message Translation
$ENV{'LANGUAGE'} = 'C';


my $stestscript = "test_script.pl";
my $itestpause = 3;
my $iteststatus = 4;

my $proctest = undef;

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
#Test: 'Read Timeout'

print "Test: 'Read Timeout' do ...\n";

$proctest = Process::SubProcess::->new(('command' => "${spath}${stestscript} $itestpause"
  , 'check' => 2, 'profiling' => 1));

isnt($proctest->getReadTimeout, -1, "Read Timeout is set");
is($proctest->isProfiling, 1, 'Profiling enabled');

is($proctest->Launch, 1, "script '$stestscript': Launch succeed");
is($proctest->Wait, 1, "script '$stestscript': Execution finished correctly");

$rscriptlog = $proctest->getReportString;
$rscripterror = $proctest->getErrorString;
$iscriptstatus = $proctest->getProcessStatus;

ok($proctest->getExecutionTime < $proctest->getReadTimeout * 2, "Measured Time is smaller than the Read Timeout");

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
#Test: 'Execution Timeout'

print "Test: 'Execution Timeout' do ...\n";

$itestpause = 4;

$proctest = Process::SubProcess::->new(('command' => "${spath}${stestscript} $itestpause"
  , 'timeout' => ($itestpause - 2)));

isnt($proctest->getTimeout, -1, "Execution Timeout is set");

is($proctest->Launch, 1, "script '$stestscript': Launch succeed");
is($proctest->Wait, 0, "script '$stestscript': Execution failed as expected");

$rscriptlog = $proctest->getReportString;
$rscripterror = $proctest->getErrorString;
$iscriptstatus = $proctest->getProcessStatus;

is($proctest->getErrorCode, 4, "ERROR CODE '4' is correct");

is($iscriptstatus, -1, "EXIT CODE was not returned");

isnt($rscripterror, undef, "STDERR Ref is returned");

if(defined $rscripterror)
{
  ok($$rscripterror =~ qr/Execution timed out/i, "STDERR has Execution Timeout");

  print("STDERR: '$$rscripterror'\n");
} #if(defined $rscripterror)

print "\n";


#------------------------
#Test: 'Script not found'

print "Test: 'Script not found' do ...\n";

$stestscript = 'no_script.sh';

$proctest = Process::SubProcess::->new(('command' => $spath . $stestscript));

is($proctest->Run, 0, "script '$stestscript': Execution failed");

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


$stestscript = 'noexec_script.pl';

$proctest = Process::SubProcess::->new(('command' => $spath . $stestscript));

is($proctest->Run, 0, "script '$stestscript': Execution failed");

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


$stestscript = 'nobashbang_script.pl';

$proctest = Process::SubProcess::->new(('command' => $spath . $stestscript));

is($proctest->Launch, 1, "script '$stestscript': Launch succeed");
is($proctest->Wait, 1, "script '$stestscript': Execution finished correctly");

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


$stestscript = 'exception_script.pl';

$proctest = Process::SubProcess::->new(('command' => $spath . $stestscript));

is($proctest->Launch, 1, "script '$stestscript': Launch succeed");
is($proctest->Wait, 1, "script '$stestscript': Execution finished correctly");

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


done_testing();

