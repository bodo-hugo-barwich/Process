#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2020-03-21
# @package SubProcess Management
# @subpackage Process/SubProcess.pm

# This Module defines the Class to manage a Subprocess and read its Output and Errors
# It forks the Main Process to execute the Sub Process Funcionality
#
#---------------------------------
# Requirements:
# - The Perl Package "perl-Data-Dump" must be installed
# - The Perl Package "perl-Time-HiRes" must be installed
#
#---------------------------------
# Features:
# - Sub Process Execution Time Out
#



#==============================================================================
# The Process::SubProcess Package

=head1 NAME

Process::SubProcess - implements a Class to manage a Sub Process and read its Output and Errors

The Idea of this API is to launch Sub Processes and keep track of all Output
on C<STDOUT>, C<STDERR>, the Exit Code and possible System Errors at Launch Time
within the Context of the External Programm.

=cut

package Process::SubProcess;

#----------------------------------------------------------------------------
#Dependencies

use Exporter 'import'; # gives you Exporter's import() method directly

our @EXPORT_OK = qw(runSubProcess);  # symbols to export on request

use POSIX ":sys_wait_h";
use POSIX qw(strftime);
use Time::HiRes qw(gettimeofday);
use IO::Select;

use Data::Dump qw(dump);

=head1 DESCRIPTION

C<Process::SubProcess> is a class which implements a Data Set which can be filled up
gradually without previous class definition.

=head1 OVERVIEW



=cut



#----------------------------------------------------------------------------
#Static Methods


sub runSubProcess
{
  my $sbprc = Process::SubProcess::new('Process::SubProcess');

  my %hshprms = undef;
  #Return the Processing Report
  my @arrrs = ();
  my $irs = 0;


  if(scalar(@_) > 1)
  {
    #Take the Method Parameters
    %hshprms = @_;
  }
  else
  {
    #One single Parameter
    %hshprms = ('command' => $_[0]);
  }

  $sbprc->setArrProcess(%hshprms);

  $irs = $sbprc->Run();


  push @arrrs, ($sbprc->getReportString) ;
  push @arrrs, ($sbprc->getErrorString) ;

  if($sbprc->getProcessStatus > -1)
  {
    push @arrrs, ($sbprc->getProcessStatus) ;
  }
  else  #The Process could not be launched
  {
    push @arrrs, ($irs) ;
  }

  $sbprc->freeResources;

  $sbprc = undef;


  return @arrrs;
}



#----------------------------------------------------------------------------
#Constructors


=head1 CONSTRUCTOR

=over 4

=item new ( [ CONFIGURATIONS ] )

This is the constructor for a new SubProcess.

C<CONFIGURATIONS> are passed in a hash like fashion, using key and value pairs.

=back

=cut

sub new {
  #Take the Method Parameters
  my ($invocant, %hshprms) =  @_;
  my $class    = ref($invocant) || $invocant;
  my $self     = undef;


  #Set the Default Attributes
  $self = {'_pid' => -1
    , '_name' => ''
    , '_command' => undef
    , '_log_pipe' => undef
    , '_error_pipe' => undef
    , '_pipe_selector'  => undef
    , '_package_size' => 8192
    , '_read_timeout' => 0
    , '_check_interval' => -1
    , '_execution_timeout' => -1
    , '_report' => ''
    , '_error_message' => ''
    , '_error_code' => 0
    , '_process_status' => -1
    , '_execution_time' => -1
    , '_profiling' => 0
    , '_debug' => 0
    , '_quiet' => 0
  };

  #Set initial Values
  $self->{'_name'} = $hshprms{'name'} if(defined $hshprms{'name'});
  $self->{'_command'} = $hshprms{'command'} if(defined $hshprms{'command'});

  #Bestow Objecthood
  bless $self, $class;

  #Execute initial Configurations
  $self->setCheckInterval($hshprms{'check'}) if(defined $hshprms{'check'});
  $self->setTimeout($hshprms{'timeout'}) if(defined $hshprms{'timeout'});
  $self->setProfiling($hshprms{'profiling'}) if(defined $hshprms{'profiling'});
  $self->setDebug($hshprms{"debug"}) if(defined $hshprms{"debug"});
  $self->setQuiet($hshprms{"quiet"}) if(defined $hshprms{"quiet"});


  #Give the Object back
  return $self;
}

sub DESTROY {
    my $self = $_[0];


	#Free the System Resources
	#$self->freeResources;
}



#----------------------------------------------------------------------------
#Administration Methods

=head1 Administration Methods

=over 4

=item setArrProcess ( CONFIGURATIONS )

This Method will asign Values to physically Data Fields.

C<CONFIGURATIONS> is a list are passed in a hash like fashion, using key and value pairs.

=back

=cut

sub setArrProcess
{
	my $self = shift;
	#Take the Method Parameters
	my %hshprms = @_;


	#Set the Name
	$self->{"_name"} = $hshprms{"name"} if(defined $hshprms{"name"});

	$self->setCheckInterval($hshprms{"check"}) if(defined $hshprms{"check"});
	$self->setTimeout($hshprms{"timeout"}) if(defined $hshprms{"timeout"});
  $self->setDebug($hshprms{"debug"}) if(defined $hshprms{"debug"});
  $self->setQuiet($hshprms{"quiet"}) if(defined $hshprms{"quiet"});

	#Attributes that cannot be changed in Running State
	unless($self->isRunning)
	{
		$self->setCommand($hshprms{"command"}) if ( defined $hshprms{"command"} );
    $self->setProfiling($hshprms{"profiling"}) if(defined $hshprms{"profiling"});
	}	#unless($self->isRunning)
}

sub set
{
	my $self = shift;
	#Take the Method Parameters
	my %hshprms = @_;


	#Set the Name
	$self->{"_name"} = $hshprms{"name"} if(defined $hshprms{"name"});

	$self->setCheckInterval($hshprms{"check"}) if(defined $hshprms{"check"});
	$self->setTimeout($hshprms{"timeout"}) if(defined $hshprms{"timeout"});
	$self->setDebug($hshprms{"debug"}) if(defined $hshprms{"debug"});
	$self->setQuiet($hshprms{"quiet"}) if(defined $hshprms{"quiet"});

	#Attributes that cannot be changed in Running State
	unless($self->isRunning)
	{
		$self->setCommand($hshprms{"command"}) if ( defined $hshprms{"command"} );
    $self->setProfiling($hshprms{"profiling"}) if(defined $hshprms{"profiling"});
	}	#unless($self->isRunning)
}

sub setName {
  my $self = $_[0];


  if(scalar(@_) > 1)
  {
    $self->{'_name'} = $_[1];
  }
  else
  {
    $self->{'_name'} = '';
  }
}

sub setCommand {
  my $self = $_[0];


	#Attributes that cannot be changed in Running State
	unless($self->isRunning)
	{
		if(scalar(@_) > 1)
		{
	    $self->{'_command'} = $_[1];
		}

    $self->{'_command'} = '' unless(defined $self->{'_command'});

    $self->{'_pid'} = -1;
    $self->{'_process_status'} = -1;
	}	#unless($self->isRunning)
}

sub setCheckInterval
{
	my $self = $_[0];


  if(scalar(@_) > 1)
  {
    if($_[0] =~ /^\d+$/)
    {
      $self->{'_check_interval'} = $_[1];
    }
    else
    {
      $self->{'_check_interval'} = -1;
    }
  }
  else #No Parameters given
  {
    #Remove the Check Interval
    $self->{'_check_interval'} = -1;
  }	#if(scalar(@_) > 0)

  $self->{'_check_interval'} = -1 unless(defined $self->{'_check_interval'});

  $self->{'_check_interval'} = -1 if($self->{'_check_interval'} < -1);

  if($self->{"_check_interval"} > 1)
  {
  	$self->{"_read_timeout"} = $self->{"_check_interval"} - 1
      if($self->{"_check_interval"} < $self->{"_read_timeout"});
  }
  else #Set the Minimum Read Timeout
  {
  	$self->{"_read_timeout"} = 1;
  }
}

sub setReadTimeout
{
  my $self = $_[0];


  if(scalar(@_) > 1)
  {
    $self->{'_read_timeout'} = $_[1];

    $self->{'_read_timeout'} = 1 unless($self->{'_read_timeout'} =~ /^-?\d+$/);
  }
  else #No Parameter was given
  {
    #Set the Minimum Read Timeout
    $self->{"_read_timeout"} = 1;
  } #if(scalar(@_) > 1)

  #Set the Minimum Read Timeout
  $self->{"_read_timeout"} = 1 unless(defined $self->{"_read_timeout"});

  #Set the Minimum Read Timeout
  $self->{"_read_timeout"} = 1 if($self->{"_read_timeout"} < 1);
}

sub setTimeout
{
	my $self = $_[0];


	if(scalar(@_) > 1)
	{
	  if($_[1] =~ /^\d+$/)
	  {
      $self->{'_execution_timeout'} = $_[1];
	  }
	  else  #The Parameter is not an unsigned whole Number
	  {
      $self->{'_execution_timeout'} = -1 ;
	  }
	}
	else #No Parameter was given
	{
	  $self->{'_execution_timeout'} = -1;
	}	#if(scalar(@_) > 1)
}

sub setProfiling
{
  my $self = shift;


  if(scalar(@_) > 0)
  {
    $self->{"_profiling"} = shift;

    #The Parameter is not a Number
    $self->{"_profiling"} = 0 unless($self->{"_profiling"} =~ /^-?\d+$/);
  }
  else  #No Parameter was given
  {
    $self->{"_profiling"} = 1;
  } #if(scalar(@_) > 1)

  $self->{"_profiling"} = 0 unless(defined $self->{"_profiling"});

  if($self->{"_profiling"} > 1)
  {
    $self->{"_profiling"} = 1;
  }
  elsif($self->{"_profiling"} < 0)
  {
    $self->{"_profiling"} = 0;
  }
}

sub setDebug
{
	my $self = shift;


	if(scalar(@_) > 0)
	{
    $self->{"_debug"} = shift;

    $self->{"_debug"} = 0 unless($self->{"_debug"} =~ /^-?\d+$/);
	}
	else	#No Parameter was given
	{
		$self->{"_debug"} = 1;
	}	#if(scalar(@_) > 0)

  $self->{"_debug"} = 1 unless(defined $self->{"_debug"});

	if($self->{"_debug"} > 1)
	{
		$self->{"_debug"} = 1;
	}
	elsif($self->{"_debug"} < 0)
	{
		$self->{"_debug"} = 0;
	}
}

sub setQuiet
{
	my $self = shift;


	if(scalar(@_) > 0)
	{
    $self->{"_quiet"} = shift;

    $self->{"_quiet"} = 0 unless($self->{"_quiet"} =~ /^-?\d+$/);
	}
	else	#No Parameter was given
	{
		$self->{"_quiet"} = 1;
	}	#if(scalar(@_) > 0)

  $self->{"_quiet"} = 1 unless(defined $self->{"_quiet"});

	if($self->{"_quiet"} > 1)
	{
		$self->{"_quiet"} = 1;
	}
	elsif($self->{"_quiet"} < 0)
	{
		$self->{"_quiet"} = 0;
	}
}

sub Launch
{
	my $self = shift;
	my $irs = 0;

	my $sprcnm  = $self->getNameComplete;


	$self->{"_report"} .= "" . (caller(0))[3] . " - go ...\n"
    if($self->{"_debug"});

  $self->{"_pid"} = -1;

	if(defined $self->{"_command"}
		&& $self->{"_command"} ne "")
	{
		local *logreader;
		local *errorreader;
		my $logwriter   = undef;
		my $errorwriter = undef;
    my $iprcpid = -1;


		pipe(*logreader, $logwriter);
		pipe(*errorreader, $errorwriter);

    $self->{"_report"} .= "Sub Process ${sprcnm}: Launching ...\n"
      if($self->{"_debug"});

		#Spawn the Child Process
		$iprcpid = fork();

		#Check the Success of Process Forking
		if(defined $iprcpid)
		{
			#------------------------
			#Sub Process Launch succeeded

			# Check whether parent/child process
			if($iprcpid > 0)
			{
				#------------------------
				#Parent Process

				close($logwriter);
				close($errorwriter);


				$self->{"_pid"} = $iprcpid;
				$self->{"_process_status"} = -1;
        $self->{"_execution_time"} = -1;

				$self->{"_log_pipe"}   = *logreader;
				$self->{"_error_pipe"} = *errorreader;

				$self->{"_pipe_selector"} = IO::Select->new();

				$self->{"_pipe_selector"}->add(*logreader);
				$self->{"_pipe_selector"}->add(*errorreader);

        $self->{"_pipe_readbytes"} = 0;

				$self->{"_report"} .= "Sub Process ${sprcnm}: Launch OK - PID ($iprcpid)\n"
				  if($self->{"_debug"});

			}
			elsif($iprcpid == 0)
			{
				#------------------------
				#Child Process

				my $ierr = 0;

        my $itmcmd = -1;
        my $itmcmdstrt = -1;
        my $itmcmdend = -1;


				close(*logreader);
				close(*errorreader);

				open(STDOUT, ">&=", $logwriter);
				open(STDERR, ">&=", $errorwriter);


        #------------------------
        #Execute the configured Command

				print "cmd: '" . $self->{"_command"} . "'\n" if($self->{"_debug"} > 0 && $self->{"_quiet"} < 1);

        #print "tired 30 sec ...\n" if($self->{"_debug"} > 0 && $self->{"_quiet"} < 1);

        #sleep 30;

        print "cmd rng ...\n" if($self->{"_debug"} > 0 && $self->{"_quiet"} < 1);

        print "cmd pfg '" . $self->{"_profiling"} . "'\n" if($self->{"_debug"} > 0 && $self->{"_quiet"} < 1);

        if($self->{"_profiling"})
        {
          $itmcmdstrt = gettimeofday;
        } #if($self->{"_profiling"})

				print `$self->{"_command"}`;

				if($self->{"_profiling"})
        {
          $itmcmdend = gettimeofday;

          $itmcmd = sprintf("%.6f", $itmcmdend - $itmcmdstrt);
        } #if($self->{"_profiling"})

				$ierr = $?;

        print "Time Execution: '$itmcmd' s\n" if($self->{"_profiling"});

        print "cmd fnshd [$ierr].\n" if($self->{"_debug"} > 0 && $self->{"_quiet"} < 1);

        #print "sleepy 30\n";

        #sleep 30;

        if($ierr >= 0)
        {
  				print "cmd stt cd: '$? / $ierr >> " . ( $ierr >> 8 ) . "'\n"
  					if($self->{"_debug"} > 0
              && $self->{"_quiet"} < 1);

          $ierr = ($ierr >> 8) if($ierr > 0);

          if($!)
          {
            #Read the Error Code
            $ierr = ($! + 0);

            #Read the Error Message
            print STDERR "Message [$ierr]: '$!'\n" unless($self->{"_quiet"});
          } #if($!)
        }
        else  #A Negative Error Code was given
        {
          if($!)
          {
            #Read the Error Code
            $ierr = ($! + 0);

            unless($self->{"_quiet"})
            {
              #Read the Error Message
              print STDERR "Command '" . $self->{"_command"} . "': Command failed with [$ierr]!\n"
                . "Message: '$!'\n";
            }
          }
          else  #Error Code is not set
          {
            #Failure without Error Code or Message
            print STDERR "Command '" . $self->{"_command"} . "': Command failed with [$ierr]!\n"
              unless($self->{"_quiet"});

            #Mark the Command as failed
            $ierr = 1;
          } #if($!)
        } #if($ierr >= 0)

        print "sb prc closing transmission ...\n" if($self->{"_debug"} > 0 && $self->{"_quiet"} < 1);


				close STDOUT;
				close STDERR;


				exit $ierr; # It is STRONGLY recommended to exit your child process
										# instead of continuing to run the parent script.
			}
			else	#An Error has ocurred in the Sub Process Launch
			{
				# Unable to fork
				$self->{"_error_message"} .= "ERROR: Sub Process '${sprcnm}' Launch failed with ["
				  . ($! + 0) . "]\n"
					. "Message: '$!'\n";

				$self->{"_error_code"} = 1 if($self->{"_error_code"} < 1);
			}	#if($iprcpid > 0)
		}
		else	#An Error has ocurred in the Process Spawning
		{
			# Unable to fork
      $self->{"_error_message"} .= "ERROR: Sub Process '${sprcnm}' Launch failed with ["
        . ($! + 0) . "]\n"
        . "Message: '$!'\n";

			$self->{"_error_code"} = 1 if($self->{"_error_code"} < 1);
		}	#if(defined $iprcpid)
	}
	else	#Executable Command is empty
	{
		$self->{"_error_message"} .= "ERROR: Sub Process '${sprcnm}' Launch failed!\n"
			. "Executable Command is not set or is empty.\n";

		$self->{"_error_code"} = 2 unless(defined $self->{"_error_code"});
		$self->{"_error_code"} = 2 if($self->{"_error_code"} < 2);

	}	#if(defined $self->{"_command"} && $self->{"_command"} ne "")

  $irs = 1 if($self->{"_pid"} > 0);


  return $irs;
}

sub Check
{
	my $self = shift;

	my $sprcnm = $self->getNameComplete;
	my $irng = 0;


  $self->{"_report"} .= "'" . (caller(1))[3] . "' : Signal to '" . (caller(0))[3] . "'\n"
    if($self->{"_debug"});

	$self->{"_report"} .= "" . (caller(0))[3] . " - go ...\n" if($self->{"_debug"});

	if(defined $self->{"_pid"}
		&& $self->{"_pid"} > -1)
	{
		#------------------------
		#Check Child Process running or finished

		my $ifnshpid = -1;


		$ifnshpid = waitpid($self->{"_pid"}, WNOHANG);

		$self->{"_report"} .= "" . (caller(0))[3] . " - wait on (" . $self->{"_pid"}
		  . ") - fnsh pid: ($ifnshpid); stt cd: [$?]\n"
			if($self->{"_debug"});

		if($ifnshpid > -1)
		{
			if($ifnshpid == 0)
			{
				#------------------------
				#The Child Process is running

				$irng = 1;

				$self->{"_report"} .= "prc (" . $self->{"_pid"} . "): Read checking ...\n"
					if($self->{"_debug"});

				#Read the Messages from the Sub Process
				$self->Read;

			}
			else	#A finished Process ID was returned
			{
				#------------------------
				#A Child Process has finished

				$self->{"_report"} .= "prc ($ifnshpid): done.\n" if($self->{"_debug"});

				if($ifnshpid == $self->{"_pid"})
				{
					#------------------------
					#The own Child Process has finished

					#Read the Process Status Code
					$self->{"_process_status"} = ( $? >> 8 );

					if ( $self->{"_process_status"} != 0 )
					{
						$self->{"_error_code"} = 1 if($self->{"_error_code"} < 1);
					}

          $self->{"_pipe_readbytes"} = 0 if($self->{"_pipe_readbytes"} < 1);

					#Read the Last Messages from the Sub Process
					$self->Read;

          #Close the Process Log Message Pipe
          close $self->{"_log_pipe"};
          #Close the Process Error Message Pipe
          close $self->{"_error_pipe"};

				}
				else	#Process ID does not match
				{
					$self->{"_error_message"} .= "ERROR: Process ($ifnshpid): "
						."Unknown Process finished.\n";

					$self->{"_error_code"} = 1 if($self->{"_error_code"} < 1);

				}	#if($ifnshpid == $self->{"_pid"})
			}	#if($ifnshpid > 0)
		}
		else	#Sub Process ID is set but the Process does not exist
		{
			if($self->{"_process_status"} < 0)
			{
				#------------------------
				#The Child Process ID was captured but no Process Status Code was captured

				$self->{"_error_message"} .= "Sub Process ${sprcnm}: Process does not exist.\n";

				$self->{"_error_code"} = 1 if($self->{"_error_code"} < 1);

			}
			else	#The Child Process has already finished
			{

			}	#if($self->{"_process_status"} < 0)
		}	#if($ifnshpid > -1)
	}
	else	#Child Process ID was not captured
	{
		$self->{"_pid"} = -1 unless(defined $self->{"_pid"});
		$self->{"_process_status"} = -1 unless(defined $self->{"_process_status"});
	}	#if(defined $self->{"_pid"} && $self->{"_pid"} > -1)


	#Return the Check Result
	return $irng;
}

sub Read
{
	my $self = $_[0];


	$self->{"_report"} .= "" . (caller(0))[3] . " - go ...\n" if($self->{"_debug"});

	#The Sub Process must have been launched
	if(defined $self->{"_pid"}
		&& defined $self->{"_process_status"}
		&& $self->{"_pid"} > 0)
	{
		my $ppsel = $self->{"_pipe_selector"};

		my $prcpp  = $self->{"_log_pipe"};
		my $prcerr = $self->{"_error_pipe"};

		my $sprcnm = $self->getNameComplete;


		unless(defined $ppsel)
		{
      #------------------------
      #Create Pipe IO Selector

			$ppsel = IO::Select->new();

			$ppsel->add($prcpp) if(defined $prcpp);
			$ppsel->add($prcerr) if(defined $prcerr);

			#Store the Pipe IO Selector Object
			$self->{"_pipe_selector"} = $ppsel;

		}	#unless(defined $self->{"_pipe_selector"})

    if(defined $ppsel)
    {
  		#------------------------
  		#Read Child Process Message Pipes

      my @arrppselrdy = undef;
      my $ppselfh     = undef;

      my $sppselfhln  = "";
      my $irdcnt = -1;

      my $stmexecsrh = "Time Execution: '([^\\']+)'";


      $self->{"_report"} .= "prc (" . $self->{"_pid"} . ") [" . $self->{"_process_status"}
        . "]: try read ...\n"
        if($self->{"_debug"});

      $self->{"_report"} .= "prc (" . $self->{"_pid"} . "): try read '" . $ppsel->count . "' pipes\n"
        if($self->{"_debug"});

  		while(@arrppselrdy = $ppsel->can_read($self->{"_read_timeout"}))
  		{
  			foreach $ppselfh (@arrppselrdy)
  			{
  			  $irdcnt = sysread($ppselfh, $sppselfhln, $self->{"_package_size"});

  			  if(defined $irdcnt)
  			  {
  					if($irdcnt > 0)
  					{
  						if(fileno($ppselfh) == fileno($prcpp))
  						{
  							$self->{"_report"} .= "pipe (" . fileno($ppselfh) . "): reading report ...\n"
                  if($self->{"_debug"});

  							$self->{"_report"} .= $sppselfhln;

  							if($self->{"_profiling"})
  							{
  							  $self->{"_execution_time"} = $1 if($sppselfhln =~ /$stmexecsrh/i);
  							}
  						}
  						elsif(fileno($ppselfh) == fileno($prcerr))
  						{
  							$self->{"_report"} .= "pipe (" . fileno($ppselfh) . "): reading error ...\n"
                  if($self->{"_debug"});

  							$self->{"_error_message"} .= $sppselfhln;
  						}	#if(fileno($ppselfh) == fileno($prcpp))
  					}
  					else	#End of Transmission
  					{
              $self->{"_report"} .= "pipe (" . fileno($ppselfh) . "): transmission done.\n"
                if($self->{"_debug"});

  					  #Remove the Pipe File Handle
              $ppsel->remove($ppselfh);

  					} #if($irdcnt > 0)
          }
          else  #Reading from the Pipe failed
          {
            #Remove the Pipe File Handle
            $ppsel->remove($ppselfh);

            if($!)
            {
              $self->{"_error_message"} .= "ERROR: Sub Process ${sprcnm}: pipe ("
                . fileno($ppselfh) . "): Read failed with [" . ($! + 0) . "]!\n"
                . "Message: '$!'\n";

              $self->{"_error_code"} = 1 if($self->{"_error_code"} < 1);

            } #if($!)
          } #if(defined $irdcnt)
  			}	#foreach $ppselfh (@arrjmselrdy)
  		} #while(@arrppselrdy = $ppsel->can_read($self->{"_read_timeout"}))

      $self->{"_report"} .= "prc (" . $self->{"_pid"} . "): try read done. '"
        . $ppsel->count . "' pipes left.\n"
        if($self->{"_debug"});
    }
    else  #Pipe IO Selector could not be created
    {
      $self->{"_error_message"} .= "ERROR: Sub Process ${sprcnm}: Read failed!\n"
        . "Message: IO Selector could not be created!\n";

      $self->{"_error_code"} = 1 if($self->{"_error_code"} < 1);

    } #if(defined $ppsel)
	}	#if(defined $self->{"_pid"} && defined $self->{"_process_status"}
		#	&& $self->{"_pid"} > 0)
}

sub Wait
{
	my $self = shift;
	#Take the Method Parameters
	my %hshprms = @_;
	my $irng = -1;
	my $irs = 0;

  my $sprcnm = $self->getNameComplete;

	my $itmchk = -1;
	my $itmchkstrt = -1;
	my $itmchkend = -1;
	my $itmrng = -1;
	my $itmrngstrt = -1;
	my $itmrngend = -1;


	print "" . (caller(0))[3] . " - go ...\n" if($self->{"_debug"} > 0 && $self->{"_quiet"} < 1);


	if(scalar(keys %hshprms) > 0)
	{
		$self->setCheckInterval($hshprms{"check"}) if(defined $hshprms{"check"});
		$self->{"_execution_timeout"} = $hshprms{"timeout"} if(defined $hshprms{"timeout"});
	}

	do	#while($irng > 0);
	{
		if($self->{"_check_interval"} > -1
			|| $self->{"_execution_timeout"} > -1)
		{
			$itmchkstrt = time;

			if($self->{"_execution_timeout"} > -1)
			{
				if($itmrngstrt < 1)
				{
					$itmrng = 0;
					$itmrngstrt = $itmchkstrt;
				}
			}	#if($self->{"_execution_timeout"} > -1)
		}	#if($self->{"_check_interval"} > -1 || $self->{"_execution_timeout"} > -1)

		#Check the Sub Process
		$irng = $self->Check;

		if($irng > 0)
		{
			if($self->{"_check_interval"} > -1
				|| $self->{"_execution_timeout"} > -1)
			{
				$itmchkend = time;
				$itmrngend = $itmchkend;

				$itmchk = $itmchkend - $itmchkstrt;
				$itmrng = $itmrngend - $itmrngstrt;

				if($self->{"_debug"} > 0
					&& $self->{"_quiet"} < 1)
				{
					print "wait tm chk: '$itmchk'\n";
					print "wait tm rng: '$itmrng'\n";
				}

				if($self->{"_execution_timeout"} > -1
					&& $itmrng >= $self->{"_execution_timeout"})
				{
					$self->{"_error_message"} .= "Sub Process ${sprcnm}: Execution timed out!\n"
						. "Execution Time '$itmrng / " . $self->{"_execution_timeout"} . "'\n"
						. "Process will be terminated.\n";

					$self->{"_error_code"} = 4 if($self->{"_error_code"} < 4);

					$self->Terminate;
					$irng = -1;
				}	#if($self->{"_execution_timeout"} > -1 && $itmrng >= $self->{"_execution_timeout"})

				if($irng > 0
					&& $itmchk < $self->{"_check_interval"})
				{
					print "wait sleep '" . ($self->{"_check_interval"} - $itmchk) . "' s ...\n"
						if($self->{"_debug"} > 0
							&& $self->{"_quiet"} < 1);

					sleep ($self->{"_check_interval"} - $itmchk);
				}
			}	#if($self->{"_check_interval"} > -1 || $self->{"_execution_timeout"} > -1)
		}	#if($irng > 0)
	}
	while($irng > 0);

	if($irng == 0)
	{
		#Mark as Finished correctly
		$irs = 1;
	}
	elsif($irng < 0)
	{
		#Mark as Failed if the Sub Process was Terminated
		$irs = 0 ;
	}	#if($irng == 0)


	return $irs;
}

sub Run
{
	my $self = shift;
	#Take the Method Parameters
	my %hshprms = @_;
	my $irs = 0;


	print "" . (caller(0))[3] . " - go ...\n" if($self->{"_debug"} > 0 && $self->{"_quiet"} < 1);

	my $sprcnm = $self->getNameComplete;


	if(scalar(keys %hshprms) > 0)
	{
		$self->setCheckInterval($hshprms{"check"}) if(defined $hshprms{"check"});
		$self->{"_execution_timeout"} = $hshprms{"timeout"} if(defined $hshprms{"timeout"});
	}

	if($self->Launch)
	{
		$irs = $self->Wait();
	}
	else	#Sub Process Launch failed
	{
		$self->{"_error_message"} .= "Sub Process ${sprcnm}: Process Launch failed!\n";
	}	#if($self->Launch)


	return $irs;
}

sub Terminate
{
	my $self = shift;
	my $sprcnm = $self->getNameComplete;


  $self->{"_error_message"} .= "'" . (caller(1))[3] . "' : Signal to '" . (caller(0))[3] . "'\n"
    if($self->{"_debug"});

	if($self->isRunning)
	{
		$self->{"_error_message"} .= "Sub Process ${sprcnm}: Process terminating ...\n";

		kill('TERM', $self->{"_pid"});

		$self->Check;
	}
	else	#Sub Process is not running
	{
		$self->{"_error_message"} .= "Sub Process ${sprcnm}: Process is not running.\n";
	}	#if($self->isRunning)
}

sub Kill
{
	my $self = shift;
	my $sprcnm = $self->getNameComplete;


  $self->{"_error_message"} .= "'" . (caller(1))[3] . "' : Signal to '" . (caller(0))[3] . "'\n"
    if($self->{"_debug"});

	if($self->isRunning)
	{
		$self->{"_error_message"} .= "Sub Process ${sprcnm}: Process killing ...\n";

		kill('KILL', $self->{"_pid"});

    #Mark Process as have been killed
    $self->{"_process_status"} = 4;
    $self->{"_error_code"} = 4 if($self->{"_error_code"} < 4);
	}
	else	#Sub Process is not running
	{
		$self->{"_error_message"} .= "Sub Process ${sprcnm}: Process is not running.\n";
	}	#if($self->isRunning)
}

sub freeResources
{
	my $self = shift;


  $self->{"_report"} .= "'" . (caller(1))[3] . "' : Signal to '" . (caller(0))[3] . "'\n"
    if($self->{"_debug"});

	if($self->isRunning > 0)
	{
		#Kill a still running Sub Process
		$self->Kill();
	}

	#Resource can only be freed if the Sub Process has terminated
	if($self->isRunning < 1)
	{
		$self->{"_log_pipe"} = undef;
		$self->{"_error_pipe"} = undef;
		$self->{"_pipe_selector"} = undef;
	}	#if($self->isRunning < 1)
}

sub clearErrors()
{
	my $self = shift;


	$self->{"_pid"} = -1;
	$self->{"_process_status"} = -1;

  $self->{"_report"} = "";
	$self->{"_error_message"} = "";
	$self->{"_error_code"}    = 0;
}



#----------------------------------------------------------------------------
#Consultation Methods


sub getProcessID {
    my $self = shift;

    return $self->{"_pid"};
}

sub getName {
    my $self = shift;

    return $self->{"_name"};
}

sub getNameComplete
{
  my $self = shift;
  my $rsnm = "";


  #Identify the Process by its PID if it is running
  $rsnm = "(" . $self->{"_pid"} . ")" if($self->{"_pid"} > -1);
  $rsnm .= " " if($rsnm ne "");
  #Identify the Process by its given Name
  $rsnm .= "'" . $self->{"_name"} . "'" if($self->{"_name"} ne "");

  #Identify the Process by its Command
  $rsnm .= "'" . $self->{"_command"} . "'" if($rsnm eq "");


  return $rsnm;
}

sub getCommand {
    my $self = shift;

    return $self->{"_command"};
}

sub getCheckInterval {
    my $self = shift;

    return $self->{"_check_interval"};
}

sub getReadTimeout
{
  my $self = shift;

  return $self->{"_read_timeout"};
}

sub getTimeout
{
  my $self = shift;

  return $self->{"_execution_timeout"};
}

sub isRunning {
    my $self = shift;
    my $irng = 0;


	#The Process got a Process ID but did not get a Process Status Code yet
	$irng = 1 if($self->{"_pid"} > 0
		&& $self->{"_process_status"} < 0);


    return $irng;
}

sub getReportString {
    my $self = shift;

    return \$self->{"_report"};
}

sub getErrorString {
    my $self = shift;

    return \$self->{"_error_message"};
}

sub getErrorCode {
    my $self = shift;

    return $self->{"_error_code"};
}

sub getProcessStatus
{
  my $self = shift;

  return $self->{"_process_status"};
}

sub getExecutionTime
{
  return $_[0]->{'_execution_time'};
}

sub isProfiling
{
  return $_[0]->{'_profiling'};
}

sub isDebug
{
  return $_[0]->{"_debug"};
}

sub isQuiet
{
  return $_[0]->{"_quiet"};
}


return 1;


