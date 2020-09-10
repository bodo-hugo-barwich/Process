#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2020-09-06
# @package Test for the Process::SubProcess::Group Module
# @subpackage test_subprocess.t

# This Module runs tests on the Process::SubProcess::Group Module
#
#---------------------------------
# Requirements:
# - The Perl Module "Process::SubProcess::Group" must be installed
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
require_ok('Process::SubProcess::Group');

use Process::SubProcess;
use Process::SubProcess::Group;



my $smodule = "";
my $spath = abs_path($0);


($smodule = $spath) =~ s/.*\/([^\/]+)$/$1/;
$spath =~ s/^(.*\/)$smodule$/$1/;


my $stestscript = "test_script.pl";
my $itestpause = 3;
my $iteststatus = 4;

my $procgroup = undef;
my $proctest = undef;

my $rscriptlog = undef;
my $rscripterror = undef;
my $iscriptstatus = -1;



#------------------------
#Test: 'Process::SubProcess::Group::Run'

my $itm = -1;
my $itmstrt = -1;
my $itmend = -1;
my $itmexe = -1;

my $iprc = -1;
my $iprccnt = -1;


print "Test: 'Process::SubProcess::Group::Run' do ...\n";

$procgroup = Process::SubProcess::Group::->new(('check' => 2));

$itestpause = 2;

$proctest = Process::SubProcess::->new(('name' => 'test-script:2s'
  , 'command' => $spath . $stestscript . ' ' . $itestpause));

$procgroup->add($proctest);

$itestpause = 3;

$proctest = Process::SubProcess::->new(('name' => 'test-script:3s'
  , 'command' => $spath . $stestscript . ' ' . $itestpause));

$procgroup->add($proctest);

$itestpause = 1;

$proctest = Process::SubProcess::->new(('name' => 'test-script:1s'
  , 'command' => $spath . $stestscript . ' ' . $itestpause));

$procgroup->add($proctest);

$iprccnt = $procgroup->getProcessCount;

is($iprccnt, 3, "scripts (count: '$iprccnt'): added correctly");


is($procgroup->Run, 1, "Process Group Execution: Execution correct");


for($iprc = 0; $iprc < $iprccnt; $iprc++)
{
  $proctest = $procgroup->getiProcess($iprc);

  isnt($proctest, undef, "Process No. '$iprc': Listed correctly");

  if(defined $proctest)
  {
    print("Process ", $proctest->getNameComplete, ":\n");

    $rscriptlog = $proctest->getReportString;
    $rscripterror = $proctest->getErrorString;
    $iscriptstatus = $proctest->getProcessStatus;

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
  } #if(defined $proctest)
} #for($iprc = 0; $iprc < $iprccnt; $iprc++)

print "\n";



#------------------------
#Test: 'Process::SubProcess::Group Execution Time'

print "Test: 'Process::SubProcess::Group Execution Time' do ...\n";

$procgroup = Process::SubProcess::Group::->new(('check' => 2));

$itestpause = 3;

$proctest = Process::SubProcess::->new(('name' => 'test-script:3s'
  , 'command' => $spath . $stestscript . ' ' . $itestpause
  , 'profiling' => 1));

is($proctest->isProfiling, 1, 'Profiling activated');

$procgroup->add($proctest);

$itestpause = 5;

$proctest = Process::SubProcess::->new(('name' => 'test-script:5s'
  , 'command' => $spath . $stestscript . ' ' . $itestpause
  , 'profiling' => 1));

is($proctest->isProfiling, 1, 'Profiling activated');

$procgroup->add($proctest);

$itestpause = 10;

$proctest = Process::SubProcess::->new(('name' => 'test-script:10s'
  , 'command' => $spath . $stestscript . ' ' . $itestpause
  , 'profiling' => 1));

is($proctest->isProfiling, 1, 'Profiling activated');

$procgroup->add($proctest);

$iprccnt = $procgroup->getProcessCount;

is($iprccnt, 3, "scripts (count: '$iprccnt'): added correctly");


$itmstrt = gettimeofday();

print "Process Group Execution Start - Time Now: '$itmstrt' s\n";

is($procgroup->Run, 1, "Process Group Execution: Execution correct");

$itmend = gettimeofday();

$itm = ($itmend - $itmstrt) * 1000;

print "Process Group Execution End - Time Now: '$itmend' s\n";

print "Process Group Execution finished in '$itm' ms\n";


for($iprc = 0; $iprc < $iprccnt; $iprc++)
{
  $proctest = $procgroup->getiProcess($iprc);

  isnt($proctest, undef, "Process No. '$iprc': Listed correctly");

  if(defined $proctest)
  {
    print("Process ", $proctest->getNameComplete, ":\n");

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
  } #if(defined $proctest)
} #for($iprc = 0; $iprc < $iprccnt; $iprc++)

print "\n";


#------------------------
#Test: 'Process::SubProcess::Group Execution Time Quiet'

print "Test: 'Process::SubProcess::Group Execution Time Quiet' do ...\n";

$procgroup = Process::SubProcess::Group::->new(('check' => 2));

$stestscript = 'quiet_script.pl';
$itestpause = 3;

$proctest = Process::SubProcess::->new(('name' => 'quiet-script:3s'
  , 'command' => $spath . $stestscript . ' ' . $itestpause
  , 'profiling' => 1));

is($proctest->isProfiling, 1, 'Profiling activated');

$procgroup->add($proctest);

$itestpause = 5;

$proctest = Process::SubProcess::->new(('name' => 'quiet-script:5s'
  , 'command' => $spath . $stestscript . ' ' . $itestpause
  , 'profiling' => 1));

is($proctest->isProfiling, 1, 'Profiling activated');

$procgroup->add($proctest);

$itestpause = 10;

$proctest = Process::SubProcess::->new(('name' => 'quiet-script:10s'
  , 'command' => $spath . $stestscript . ' ' . $itestpause
  , 'profiling' => 1));

is($proctest->isProfiling, 1, 'Profiling activated');

$procgroup->add($proctest);

$iprccnt = $procgroup->getProcessCount;

is($iprccnt, 3, "scripts (count: '$iprccnt'): added correctly");

$procgroup->setCheckInterval(2);

isnt($procgroup->getCheckInterval, -1, "Read Timeout activated");


$itmstrt = gettimeofday();

print "Process Group Execution Start - Time Now: '$itmstrt' s\n";

is($procgroup->Run, 1, "Process Group Execution: Execution correct");

$itmend = gettimeofday();

$itm = ($itmend - $itmstrt) * 1000;

print "Process Group Execution End - Time Now: '$itmend' s\n";

print "Process Group Execution finished in '$itm' ms\n";


for($iprc = 0; $iprc < $iprccnt; $iprc++)
{
  $proctest = $procgroup->getiProcess($iprc);

  isnt($proctest, undef, "Process No. '$iprc': Listed correctly");

  if(defined $proctest)
  {
    print("Process ", $proctest->getNameComplete, ":\n");

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
  } #if(defined $proctest)
} #for($iprc = 0; $iprc < $iprccnt; $iprc++)

print "\n";


#------------------------
#Test: 'Process::SubProcess::Group Execution Timeout'

print "Test: 'Process::SubProcess::Group Execution Timeout' do ...\n";

$procgroup = Process::SubProcess::Group::->new(('check' => 2, 'timeout' => 9));

$stestscript = "test_script.pl";
$itestpause = 3;

$proctest = Process::SubProcess::->new(('name' => 'test-script:3s'
  , 'command' => $spath . $stestscript . ' ' . $itestpause
  , 'profiling' => 1));

is($proctest->isProfiling, 1, 'Profiling activated');

$procgroup->add($proctest);

$itestpause = 5;

$proctest = Process::SubProcess::->new(('name' => 'test-script:5s'
  , 'command' => $spath . $stestscript . ' ' . $itestpause
  , 'profiling' => 1));

is($proctest->isProfiling, 1, 'Profiling activated');

$procgroup->add($proctest);

$itestpause = 10;

$proctest = Process::SubProcess::->new(('name' => 'test-script:10s'
  , 'command' => $spath . $stestscript . ' ' . $itestpause
  , 'profiling' => 1));

is($proctest->isProfiling, 1, 'Profiling activated');

$procgroup->add($proctest);

$iprccnt = $procgroup->getProcessCount;

is($iprccnt, 3, "scripts (count: '$iprccnt'): added correctly");

$procgroup->setCheckInterval(2);

isnt($procgroup->getCheckInterval, -1, "Read Timeout activated");
isnt($procgroup->getTimeout, -1, "Execution Timeout activated");


$itmstrt = gettimeofday();

print "Process Group Execution Start - Time Now: '$itmstrt' s\n";

is($procgroup->Run, 0, "Process Group Execution: Execution failed as expected");

$itmend = gettimeofday();

$itm = ($itmend - $itmstrt) * 1000;

print "Process Group Execution End - Time Now: '$itmend' s\n";

print "Process Group Execution finished in '$itm' ms\n";

print("Process Group ERROR CODE: '" .  $procgroup->getErrorCode .  "'\n");

is($procgroup->getErrorCode, 4, "Process Group Execution: ERROR CODE is correct");

print("Process Group STDOUT: '" . ${$procgroup->getReportString} . "'\n");
print("Process Group STDERR: '" . ${$procgroup->getErrorString} . "'\n");


for($iprc = 0; $iprc < $iprccnt; $iprc++)
{
  $proctest = $procgroup->getiProcess($iprc);

  isnt($proctest, undef, "Process No. '$iprc': Listed correctly");

  if(defined $proctest)
  {
    print("Process ", $proctest->getNameComplete, ":\n");

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
  } #if(defined $proctest)
} #for($iprc = 0; $iprc < $iprccnt; $iprc++)

print "\n";


done_testing();
