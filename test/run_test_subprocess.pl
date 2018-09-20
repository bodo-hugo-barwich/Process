#!/usr/bin/perl

=pod
# @author Bodo (Hugo) Barwich
# @version 2018-06-14
# @package Test for the Process::SubProcess Module
# @subpackage run_test_subprocess.pl

# This Module runs tests on the Process::SubProcess Module
#
#---------------------------------
# Requirements:
# - The Perl Module "Process::SubProcess" must be installed 
#
=cut


BEGIN
{
  use lib "lib";
  use lib "../lib";
}  #BEGIN


use Test::More; 

require_ok('Process::SubProcess');



my $stestscript = "test_subprocess.pl";
my $iscriptpause = 3;

my $scriptlog = undef;
my $scripterror = undef;
my $scriptstatus = -1;



($scriptlog, $scripterror, $scriptstatus) = runSubProcess(("command" => "$stestscript $iscriptpause"));



