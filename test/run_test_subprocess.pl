#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2020-03-21
# @package Test for the Process::SubProcess Module
# @subpackage run_test_subprocess.pl

# This Module runs tests on the Process::SubProcess Module
#
#---------------------------------
# Requirements:
# - The Perl Module "Process::SubProcess" must be installed
#



use warnings;
use strict;

use Test::More;

BEGIN
{
  use lib "lib";
  use lib "../lib";
}  #BEGIN

require_ok('Process::SubProcess');

#use Process::SubProcess;



my $stestscript = "test_subprocess.pl";
my $iscriptpause = 3;

my $scriptlog = undef;
my $scripterror = undef;
my $scriptstatus = -1;



($scriptlog, $scripterror, $scriptstatus) = Process::SubProcess::runSubProcess(("command" => "$stestscript $iscriptpause"));



