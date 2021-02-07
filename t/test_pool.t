#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2021-02-05
# @package Test for the Process::SubProcess::Pool Module
# @subpackage test_pool.t

# This Module runs tests on the Process::SubProcess::Pool Module
#
#---------------------------------
# Requirements:
# - The Perl Module "Process::SubProcess::Pool" must be installed
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
require_ok('Process::SubProcess::Pool');

use Process::SubProcess;
use Process::SubProcess::Pool;



my $smodule = '';
my $spath = abs_path($0);


($smodule = $spath) =~ s#.*\/([^\/]+)$#$1#;
$spath =~ s#^(.*\/)$smodule$#$1#;


my $stestscript = 'test_script.pl';
my $itestpause = 3;
my $iteststatus = 4;

my $procpool = undef;
my $proctest = undef;
my @arrprocs = ();

my $rscriptlog = undef;
my $rscripterror = undef;
my $iscriptstatus = -1;


#------------------------
#Test: 'Process::SubProcess::Pool::waitNext() Method'

my $itm = -1;
my $itmstrt = -1;
my $itmend = -1;
my $itmexe = -1;

my $iprc = -1;
my $iprccnt = -1;

my $iprcrngcnt = -1;
my $iprcexecnt = -1;
my $iprctmoutcnt = -1;
my $iprcaddrs = 0;



print "Test: 'Process::SubProcess::Pool::waitNext() Method' do ...\n";

$procpool = Process::SubProcess::Pool::->new(('timeout' => 7, 'maxprocesscount' => 2));

$stestscript = "test_script.pl";
$itestpause = 3;
$proctest = Process::SubProcess::->new(('name' => "test-script:${itestpause}s"
  , 'command' => $spath . $stestscript . ' ' . $itestpause
  , 'profiling' => 1));

is($proctest->isProfiling, 1, 'Profiling activated');

push @arrprocs, {'proc' => $proctest, 'running' => 0};

$itestpause = 5;
$proctest = Process::SubProcess::->new(('name' => "test-script:${itestpause}s"
  , 'command' => $spath . $stestscript . ' ' . $itestpause
  , 'profiling' => 1));

is($proctest->isProfiling, 1, 'Profiling activated');

push @arrprocs, {'proc' => $proctest, 'running' => 0};

$itestpause = 10;
$proctest = Process::SubProcess::->new(('name' => "test-script:${itestpause}s"
  , 'command' => $spath . $stestscript . ' ' . $itestpause
  , 'profiling' => 1));

is($proctest->isProfiling, 1, 'Profiling activated');

push @arrprocs, {'proc' => $proctest, 'running' => 0};

$itestpause = 1;
$proctest = Process::SubProcess::->new(('name' => "test-script:${itestpause}s"
  , 'command' => $spath . $stestscript . ' ' . $itestpause
  , 'profiling' => 1));

is($proctest->isProfiling, 1, 'Profiling activated');

push @arrprocs, {'proc' => $proctest, 'running' => 0};

$itestpause = 2;
$proctest = Process::SubProcess::->new(('name' => "test-script:${itestpause}s"
  , 'command' => $spath . $stestscript . ' ' . $itestpause
  , 'profiling' => 1));

is($proctest->isProfiling, 1, 'Profiling activated');

push @arrprocs, {'proc' => $proctest, 'running' => 0};

$iprccnt = scalar(@arrprocs);

is($iprccnt, 5, "scripts (count: '$iprccnt'): added correctly");

$procpool->setCheckInterval(6);

isnt($procpool->getCheckInterval, -1, "Check Interval activated");
isnt($procpool->getTimeout, -1, "Execution Timeout activated");


$itmstrt = gettimeofday();

print "Process Pool Execution Start - Time Now: '$itmstrt' s\n";

$iprcexecnt = 0;

do
{
  $iprcrngcnt = 0;

  for($iprc = 0; $iprcrngcnt < $procpool->getMaxProcessCount && $iprc < $iprccnt; $iprc++)
  {
    $proctest = $arrprocs[$iprc]{'proc'};
    $iprcaddrs = 0;

    $iprcaddrs = $procpool->add($proctest)
      unless($arrprocs[$iprc]{'running'});

    if($iprcaddrs)
    {
      $iprcaddrs = $proctest->Launch;

      is($iprcaddrs, 1, "Process No. '$iprc': Launch succeeded");

      if($iprcaddrs)
      {
        $arrprocs[$iprc]{'running'} = 1;

        $iprcrngcnt++;
      } #if($iprcaddrs)
    } #if($iprcaddrs)
  } #for($iprc = 0; $iprc < $iprccnt; $iprc++)

  #Check how many Processes have been launched
  $iprcrngcnt = $procpool->getRunningCount;

  $procpool->waitNext;

  while(defined($proctest = $procpool->getFinishedProcess))
  {




    #Count the finished Processes
    $iprcexecnt++;

  } #while(defined($proctest = $procpool->getFinishedProcess))

}
while($iprcexecnt < $iprccnt
  && $procpool->getErrorCode == 0);

$itmend = gettimeofday();

$itm = ($itmend - $itmstrt) * 1000;

print "Process Pool Execution End - Time Now: '$itmend' s\n";

print "Process Pool Execution finished in '$itm' ms\n";







for($iprc = 0; $iprc < $iprccnt; $iprc++)
{
  $proctest = $procpool->getiProcess($iprc);

  isnt($proctest, undef, "Process No. '$iprc': Listed correctly");

  if(defined $proctest)
  {
    #Launch Child Processes seperately
    is($proctest->Launch, 1, "Process No. '$iprc': Launch succeeded");
  } #if(defined $proctest)
} #for($iprc = 0; $iprc < $iprccnt; $iprc++)

is($procpool->getRunningCount, 3, "Process Group Execution: All Processes are launched");

is($procpool->Wait(), 0, "Process Group Execution: Execution failed as expected");

print("Process Pool ERROR CODE: '" .  $procpool->getErrorCode .  "'\n");

is($procpool->getErrorCode, 4, "Process Group Execution: ERROR CODE is correct");

print("Process Pool STDOUT: '" . ${$procpool->getReportString} . "'\n");
print("Process Pool STDERR: '" . ${$procpool->getErrorString} . "'\n");

$iprctmoutcnt = 0 if($procpool->getErrorCode == 4);

for($iprc = 0; $iprc < $iprccnt; $iprc++)
{
  $proctest = $procpool->getiProcess($iprc);

  isnt($proctest, undef, "Process No. '$iprc': Listed correctly");

  if(defined $proctest)
  {
    print("Process ", $proctest->getNameComplete, " finished with [" . $proctest->getErrorCode . "]:\n");

    $rscriptlog = $proctest->getReportString;
    $rscripterror = $proctest->getErrorString;
    $iscriptstatus = $proctest->getProcessStatus;

    print("ERROR CODE: '", $proctest->getErrorCode, "'\n");
    print("EXIT CODE: '$iscriptstatus'\n");

    if($proctest->getErrorCode == 4)
    {
      $iprctmoutcnt++ ;

      is($proctest->getExecutionTime, -1, "Execution Time not measured as expected");
    }
    else  #Timeout Error
    {
      isnt($proctest->getExecutionTime, -1, "Execution Time was measured");
    } #if($proctest->getErrorCode == 4)

    print("Read Timeout: '", $proctest->getReadTimeout, "'\n");
    print("Execution Time: '", $proctest->getExecutionTime, "'\n");

    if(defined $rscriptlog)
    {
      print("STDOUT: '$$rscriptlog'\n");
    }
    else
    {
      isnt($rscriptlog, undef, "STDOUT was captured");
    } #if(defined $rscriptlog)

    if(defined $rscripterror)
    {
      print("STDERR: '$$rscripterror'\n");
    }
    else
    {
      isnt($rscripterror, undef, "STDERR was captured");
    } #if(defined $rscripterror)
  } #if(defined $proctest)
} #for($iprc = 0; $iprc < $iprccnt; $iprc++)

is($iprctmoutcnt, 1, "'1' Process timed out as expected");

print("Process Pool Execution Timeout - Count: '$iprctmoutcnt'\n");

print "\n";


done_testing();
