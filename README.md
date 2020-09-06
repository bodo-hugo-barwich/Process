# Process
Running Sub Processes in an easy way while reading STDOUT, STDERR, Exit Code and possible System Errors. \
It also implements running multiple Sub Processes simultaneously while keeping all Report and Error Messages and Exit Codes 
seperate.

# Motivation
This Module was conceived out of the need to launch multiple Tasks simulaneously while still keeping each Log and Error Messages and Exit Codes separately. \
As I developed it as Prototype at:
[Multi Process Manager](https://stackoverflow.com/questions/50177534/why-do-pipes-from-child-processes-break-sometimes-and-sometimes-not)\
The **Object Oriented Design** permits the implementation of the **[Command Pattern / Manager-Worker Pattern](https://en.wikipedia.org/wiki/Command_pattern)** with the `Process::SubProcess::Group` and `Process::SubProcess::Pool` Packages.\
Having a similar implementation as the [`Capture::Tiny` Package](https://metacpan.org/pod/Capture::Tiny) it eventually evolved as a Procedural Replacement for the `Capture::Tiny::capture()` Function.

# Usage
## runSubProcess() Function
Demonstrating the `runSubProcess()` Function Use Case:
```perl
use Process::SubProcess qw(runSubProcess);

use Test::More;


my $stestscript = "test_script.pl";
my $spath = '/path/to/test/script/';

my $rscriptlog = undef;
my $rscripterror = undef;
my $iscriptstatus = -1;


#Execute the Command
($rscriptlog, $rscripterror, $iscriptstatus) = runSubProcess($spath . $stestscript);

#Evaluate the Results

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

done_testing();
```

# Features
Some important Features are:
* Asynchronous Launch
* Reads Big Outputs
* Execution Timeout
* Configurable Read Interval
* Captures possible System Errors at Launch Time like "file not found" Errors
