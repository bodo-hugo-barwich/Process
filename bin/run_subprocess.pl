#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2023-07-06
# @package Process::SubProcess
# @subpackage bin/run_subprocess.pl

# This Module spawns a sub process from the commandline options and prints the results
# to the STDOUT in a structured parseable output.
#

use strict;
use warnings;

use Getopt::Long::Descriptive;
use Path::Tiny qw(path);
use JSON qw(encode_json);
use YAML qw(Dump);
use Data::Dump qw(dump);

BEGIN {
    use lib "lib";
    use lib "../lib";
}    #BEGIN

use Process::SubProcess;

# ==============================================================================
# Executing Section

# ------------------------
# Script Environment

my $module_file = path($0)->basename;
my $path        = Path::Tiny->cwd;
my $maindir     = $path;

# ------------------------
# Script Parameter

my ( $opt, $usage ) = describe_options(
    '%c %o',
    [ 'command|c=s', 'the COMMAND to be run',    { 'required' => 1 } ],
    [ 'name|n=s',    'the NAME for the COMMAND', { 'default'  => '' } ],
    [
        'readtimeout|r=i',
        'the TIMEOUT for reading of the output from COMMAND',
        { 'default' => -1 }
    ],
    [
        'timeout|t=i',
        'the TIMEOUT for execution the COMMAND',
        { 'default' => -1 }
    ],
    [ 'exit|x',     'execution returns exit code', { 'default' => 0 } ],
    [ 'format|f=s', 'the format for the output',   { 'default' => 'plain' } ],
    [
        'boundary|b=s',
        'boundary string for the plain text output',
        { 'default' => '>>>>' }
    ],
    [ 'debug|d', 'execution debug output' ],
    [ 'help|h',  "print usage message and exit", { 'shortcircuit' => 1 } ],
);

if ( $opt->help ) {
    print( $usage->text );

    exit;
}

my %command_res = (
    'command'    => $opt->command,
    'pid'        => -1,
    'name'       => $opt->name,
    'stdout'     => '',
    'stderr'     => '',
    'exit_code'  => -1,
    'error_code' => 0
);

if ( $opt->command ne '' ) {
    my $process =
      Process::SubProcess->new( 'command' => $command_res{'command'} );

    $process->setName( $command_res{'name'} ) if ( $command_res{'name'} ne '' );

    $process->setReadTimeout( $opt->readtimeout )
      if ( $opt->readtimeout != -1 );
    $process->setTimeout( $opt->timeout ) if ( $opt->timeout != -1 );

    $process->Run();

    if ( $opt->debug ) {
        print "proc dmp:\n", dump($process), "\n";
    }

    $command_res{'pid'}        = $process->getProcessID;
    $command_res{'exit_code'}  = $process->getProcessStatus;
    $command_res{'error_code'} = $process->getErrorCode;

    $command_res{'stdout'} = ${ $process->getReportString };
    $command_res{'stderr'} = ${ $process->getErrorString };
}
else {
    $command_res{'error_code'} = 3;
    $command_res{'stderr'} =
      "script '$module_file' - Command Error: Command is missing!";
}

# ------------------------
# Print the Command Result

if ( $opt->format eq 'plain' ) {
    print "script '$module_file' - Command Result:\n";

    printf "%sSUMMARY:\n", $opt->boundary;
    printf "command: %s\nname: %s\npid: %d\nexit code: %d\nerror code: %d\n",
      $command_res{'command'}, $command_res{'name'}, $command_res{'pid'},
      $command_res{'exit_code'}, $command_res{'error_code'};

    printf "%sSTDOUT:\n", $opt->boundary;
    print $command_res{'stdout'};

    printf "%sSTDERR:\n", $opt->boundary;
    print $command_res{'stderr'};

    printf "%sEND%s\n", $opt->boundary, $opt->boundary;
}
elsif ( $opt->format eq 'json' ) {
    print encode_json( \%command_res );
}
elsif ( $opt->format eq 'yaml' ) {
    print Dump( \%command_res );
}
else {
    print "script '$module_file' - Command Result:\n", dump( \%command_res ),
      "\n";
}

if ( $opt->exit ) {
  	if ( $command_res{'exit_code'} > -1 ) {
  		  exit $command_res{'exit_code'};
  	}
  	else {
  		  exit $command_res{'error_code'};
  	}
}
