#!/usr/bin/perl

=pod
# @author Bodo (Hugo) Barwich
# @version 2018-06-14
# @package SubProcess Management
# @subpackage Spawn Subprocesses and read their Output and Errors

# This Module defines Classes to manage multiple Subprocesses read their Output and Errors
# It forks the Main Process to execute the Sub Process Funcionality
#
#---------------------------------
# Requirements:
# - The Perl Package "perl-Data-Dump" must be installed 
#
#---------------------------------
# Features:
# - Sub Process Execution Time Out
#
=cut



#==============================================================================
# The SubProcessGroup Package


package SubProcessGroup;

#----------------------------------------------------------------------------
#Dependencies


use POSIX qw(strftime);
use Scalar::Util 'blessed';
use Data::Dump qw(dump);



#----------------------------------------------------------------------------
#Constructors


sub new {
    my $invocant = shift;
    my $class    = ref($invocant) || $invocant;
    my $self     = undef;

    #Take the Method Parameters
    my %hshprms = @_;


    #Set the Default Attributes and assign the initial Values
    $self = {
        "_array_processes" => (),
        "_list_processes"  => (),
        "_check_interval" => -1,
        "_execution_timeout" => -1,        
        "_report"          => "",
        "_error_message"   => "",
        "_error_code"      => 0,
        "_profiling" => 0,
        "_debug" => 0,
        "_quiet" => 0
    };

    #Set initial Values
    $self->{"_execution_timeout"} = $hshprms{"timeout"} if(defined $hshprms{"timeout"});
    $self->{"_debug"} = $hshprms{"debug"} if(defined $hshprms{"debug"});
    $self->{"_quiet"} = $hshprms{"quiet"} if(defined $hshprms{"quiet"});

    #Bestow Objecthood
    bless $self, $class;

    #Execute initial Configurations
    $self->setCheckInterval($hshprms{"check"}) if(defined $hshprms{"check"});


    #Give the Object back
    return $self;
}

sub DESTROY {
    my $self = shift;


  #Free the System Resources
  #$self->freeResources;
}



#----------------------------------------------------------------------------
#Administration Methods


sub add
{
	my $self = shift;

  my $rsprc = undef;
	my $sprctp = "";


	print "" . (caller(0))[3] . " - go ...\n" if($self->{"_debug"} > 0 && $self->{"_quiet"} < 1);
	
	if(scalar(@_) > 0)
	{
		#Read the 2nd Parameter
		$rsprc = shift ;
	}

	#2nd Parameter is given	
	if(defined $rsprc)
	{
		$sprctp = blessed $rsprc;
	
		#The 2nd Parameter is not an Object
		unless(defined $sprctp)
		{
			#Scalar Parameter has been given
			$sprctp = $rsprc;
			#No Object has been given
			$rsprc = undef;
	
			#Read the 3rd Parameter
			$rsprc = shift if(scalar(@_) > 0);
			
		}	#unless(defined $sprctp)
	}	#if(defined $rsprc)
	
	unless(defined $rsprc)
	{
		if($sprctp ne "")
		{
			$rsprc = $sprctp->new;
    }
    else  #No Parameters given
    {
      #Create a SubProcess Object by Default
      $rsprc = SubProcess::->new;
    }
  } #unless(defined $rsprc)
    
  if($self->{"_debug"} > 0 
    && $self->{"_quiet"} < 1)
  {  
  	print "self 0 dmp:\n"
  		. dump ($self);
  	print "\n";
  
  	print "rs prc 1 dmp:\n"
  		. dump ($rsprc);
  	print "\n";
  } #if($self->{"_debug"} > 0 && $self->{"_quiet"} < 1)

  if(defined $rsprc)
  {
  	unless ( $rsprc->isa("ChildProcess")
  		|| $rsprc->isa("SubProcess") )
  	{
  		$rsprc = undef;
      	
  		$rsprc = SubProcess::->new;
  	}
  }
  else  #Sub Process Object was not created yet
  {
    #Create a SubProcess Object by Default
    $rsprc = SubProcess::->new;
  } #if(defined $rsprc)

	if(defined $rsprc)
	{
		if($rsprc->isa("ChildProcess")
			|| $rsprc->isa("SubProcess"))
		{
			push @{$self->{_array_processes}}, ($rsprc);

      $rsprc->setCheckInterval($self->{"_check_interval"})
        if(defined $self->{"_check_interval"});
        
		} #if($rsprc->isa("ChildProcess") || $rsprc->isa("SubProcess"))
	}	#if(defined $rsprc)
		

  if($self->{"_debug"} > 0 
    && $self->{"_quiet"} < 1)
  {  
  	print "self 1 dmp:\n"
  		. dump ($self);
  	print "\n";
  }


	#Give the Object back
	return $rsprc;
}

sub setCheckInterval
{
  my $self = shift;
  
  
  if(scalar(@_) > 0)
  {
    $self->{"_check_interval"} = shift;
    
    #The Parameter is not a Number
    $self->{"_check_interval"} = -1 unless($self->{"_check_interval"} =~ /^-?\d+$/);
  }
  else  #No Parameters given
  {
    #Remove the Check Interval
    $self->{"_check_interval"} = -1;
  } #if(scalar(@_) > 0)
    
  $self->{"_check_interval"} = -1 unless(defined $self->{"_check_interval"});
  
  if(defined $self->{"_array_processes"})
  {
    my $sbprc = undef;
    

    foreach $sbprc (@{$self->{"_array_processes"}})
    {
      #Communicate the Change to all Sub Processes
      $sbprc->setCheckInterval($self->{"_check_interval"});
      
    } #foreach $sbprc (@{$self->{"_array_processes"}})
  } #if(defined $self->{"_array_processes"}) 
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
  else  #No Parameters given
  {
    #Remove the Check Interval
    $self->{"_profiling"} = 1;
  } #if(scalar(@_) > 0)
    
  $self->{"_profiling"} = 0 unless(defined $self->{"_profiling"});
  
  if(defined $self->{"_array_processes"})
  {
    my $sbprc = undef;
    

    foreach $sbprc (@{$self->{"_array_processes"}})
    {
      #Communicate the Change to all Sub Processes
      $sbprc->setProfiling($self->{"_profiling"});
      
    } #foreach $sbprc (@{$self->{"_array_processes"}})
  } #if(defined $self->{"_array_processes"})
  
}

sub Launch
{
	my $self = shift;
	my $irs = 0;
 
 
  if($self->{"_debug"} > 0 
    && $self->{"_quiet"} < 1)
  {  
    print "" . (caller(0))[3] . " - go ...\n";
    print "arr prcs cnt: '" . scalar(@{$self->{"_array_processes"}}) . "'\n";
  }

	if(defined $self->{"_array_processes"})
	{
    my $sbprc = undef;
    my $sprcnm = "";
		my $iprcidx = 0;
		my $iprccnt = scalar(@{$self->{"_array_processes"}});
		
	  my @arrnow = undef;
		my $sdate = "";
		my $stime = "";
    
		
		for($iprcidx = 0; $iprcidx < $iprccnt; $iprcidx++)
		{
			$sbprc = $self->{"_array_processes"}[$iprcidx];

			if(defined $sbprc)
			{
				$sprcnm = "No. '$iprcidx' - " . $sbprc->getNameComplete;
			
			  if($self->{"_debug"} > 0 
          && $self->{"_quiet"} < 1)
        {  			
        	print "sb prc no. '$iprcidx' dmp:\n"
        		. dump ($sbprc);
        	print "\n";
        }
                
				@arrnow = localtime;
				$sdate  = strftime( "%F", @arrnow );
				$stime  = strftime( "%T", @arrnow );

				$self->{"_report"} .= "${sdate} ${stime} : Sub Process ${sprcnm}: Launching ...\n";


				if($sbprc->Launch)
				{
					@arrnow = localtime;
					$sdate  = strftime( "%F", @arrnow );
					$stime  = strftime( "%T", @arrnow );
	
					$self->{"_report"} .= "${sdate} ${stime} : Sub Process ${sprcnm}: Launch OK "
						. "- PID (" . $sbprc->getProcessID . ")\n";

					$irs++ ;
				}
				else  #Sub Process Launch failed
				{
					$self->{"_error_code"} = $sbprc->getErrorCode  
						if($sbprc->getErrorCode > $self->{"_error_code"});
						
					$self->{"_error_message"} .= "Sub Process ${sprcnm}: Launch failed!"
						. "Message: " . $sbprc->getErrorString;		
				}	#if($sbprc->Launch)
			}	#if(defined $sbprc)
		}	#foreach $sbprc (@{$self->{"_array_processes"}})
	}	#if(defined $self->{"_array_processes"})


	return $irs;
}

sub Check
{
	my $self = shift;
	my $irs = 0;


  if($self->{"_debug"} > 0 
    && $self->{"_quiet"} < 1)
  {  
    print "" . (caller(0))[3] . " - go ...\n";
    print "arr prcs cnt: '" . scalar(@{$self->{"_array_processes"}}) . "'\n";
  }

	if(defined $self->{"_array_processes"})
	{
    my $sbprc = undef;
    my $sprcnm = "";
    
	  my @arrnow = undef;
		my $sdate = "";
		my $stime = "";
		

		foreach $sbprc (@{$self->{"_array_processes"}})
		{
			$sprcnm = $sbprc->getNameComplete;

      $self->{"_report"} .= "Sub Process ${sprcnm}: checking ...\n"
        if($self->{"_debug"} > 0
          && $self->{"_quiet"} < 1);
			
			if($sbprc->isRunning)
			{
				if($sbprc->Check)
				{
					#Count the Running Sub Processes
					$irs++ ;
				}
				else	#The Sub Process has finished
				{
					@arrnow = localtime;
					$sdate  = strftime( "%F", @arrnow );
					$stime  = strftime( "%T", @arrnow );
	
					$self->{"_report"} .= "${sdate} ${stime} : Sub Process ${sprcnm}: "
						. "finished with [" . $sbprc->getProcessStatus . "]\n";
						
					#$sbprc->freeResources;
				}	#if($sbprc->Check)
			}
			else	#The Sub Process is already finished
			{
				$self->{"_report"} .= "Sub Process ${sprcnm}: "
					. "already finished with [" . $sbprc->getProcessStatus . "]\n"
          if($self->{"_debug"} > 0
            && $self->{"_quiet"} < 1);
						
				#$sbprc->freeResources;
				
			}	#if($sbprc->isRunning)
		}	#foreach $sbprc (@{$self->{"_array_processes"}})
	}	#if(defined $self->{"_array_processes"})

    
	return $irs;	
}

sub checkiProcess
{
  my $self = shift;
  my $sbprc = undef;
  my $iidx = shift;
  my $irs = 0;


  $sbprc = $self->getiProcess($iidx);
  
  if(defined $sbprc)
  {
    $irs = 0;
    
    $irs = $sbprc->Check if($sbprc->isRunning);
  } #if(defined $sbprc)
  
  
  return $irs;
}

sub Wait
{
  my $self = shift;
  #Take the Method Parameters
  my %hshprms = @_;
  my $irng = -1;
  my $irs = 0;

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
  
  do  #while($irng > 0);
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
      } #if($self->{"_execution_timeout"} > -1)
    } #if($self->{"_check_interval"} > -1 || $self->{"_execution_timeout"} > -1)
    
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
          $self->{"_error_message"} .= "Sub Processes 'Count: $irng': Execution timed out!\n"
            . "Execution Time '$itmrng / " . $self->{"_execution_timeout"} . "'\n"
            . "Processes will be terminated.\n";

          $self->{"_error_code"} = 4 if($self->{"_error_code"} < 4);
      
          $self->Terminate;
          $irng = -1;
        } #if($self->{"_execution_timeout"} > -1 && $itmrng >= $self->{"_execution_timeout"})
                  
        if($irng > 0
          && $itmchk < $self->{"_check_interval"})
        {
          print "wait sleep '" . ($self->{"_check_interval"} - $itmchk) . "' s ...\n" 
            if($self->{"_debug"} > 0 
              && $self->{"_quiet"} < 1);
          
          sleep ($self->{"_check_interval"} - $itmchk);
        }
      } #if($self->{"_check_interval"} > -1 || $self->{"_execution_timeout"} > -1)
    } #if($irng > 0)
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
  } #if($irng == 0)
  
  
  return $irs;
}

sub Run
{
  my $self = shift;
  #Take the Method Parameters
  my %hshprms = @_;
  my $irs = 0;


  print "" . (caller(0))[3] . " - go ...\n" if($self->{"_debug"} > 0 && $self->{"_quiet"} < 1);

  if(scalar(keys %hshprms) > 0)
  { 
    $self->setCheckInterval($hshprms{"check"}) if(defined $hshprms{"check"});
    $self->{"_execution_timeout"} = $hshprms{"timeout"} if(defined $hshprms{"timeout"});
  }
  
  if($self->Launch)
  {   
    $irs = $self->Wait();
  }
  else  #Sub Process Launch failed
  {
    $self->{"_error_message"} .= "Sub Processes: Process Launch failed!\n";
  } #if($self->Launch)
  
  
  return $irs;  
}

sub Terminate
{
  my $self = shift;
  
  
  $self->{"_report"} .= "'" . (caller(1))[3] . "' : Signal to '" . (caller(0))[3] . "'\n"
    if($self->{"_debug"});
  $self->{"_error_message"} .= "Sub Processes: Processes terminating ...\n";
  
  if(defined $self->{"_array_processes"})
  {
    my $sbprc = undef;
  
  
    foreach $sbprc (@{$self->{"_array_processes"}})
    {
      if($sbprc->isRunning)
      {
        #Terminate the Sub Process
        $sbprc->Terminate;
      } #if($sbprc->isRunning)      
    } #foreach $sbprc (@{$self->{"_array_processes"}})
  } #if(defined $self->{"_array_processes"})
  
}

sub Kill
{
  my $self = shift;
  
  
  $self->{"_report"} .= "'" . (caller(1))[3] . "' : Signal to '" . (caller(0))[3] . "'\n"
    if($self->{"_debug"});
  $self->{"_error_message"} .= "Sub Processes: Processes killing ...\n";
  
  if(defined $self->{"_array_processes"})
  {
    my $sbprc = undef;
  
  
    foreach $sbprc (@{$self->{"_array_processes"}})
    {
      if($sbprc->isRunning)
      {
        #Kill the Sub Process
        $sbprc->Kill;
      } #if($sbprc->isRunning)      
    } #foreach $sbprc (@{$self->{"_array_processes"}})
  } #if(defined $self->{"_array_processes"})
}

sub freeResources
{
  my $self = shift;


  $self->{"_report"} .= "'" . (caller(1))[3] . "' : Signal to '" . (caller(0))[3] . "'\n"
    if($self->{"_debug"});

  if(defined $self->{"_array_processes"})
  {
    my $sbprc = undef;
  
  
    foreach $sbprc (@{$self->{"_array_processes"}})
    {
      #Free all Sub Processes System Resources
      $sbprc->freeResources;      
    } #foreach $sbprc (@{$self->{"_array_processes"}})
  } #if(defined $self->{"_array_processes"})
}

sub clearErrors()
{
  my $self = shift;

    
  $self->{"_report"} .= "'" . (caller(1))[3] . "' : Signal to '" . (caller(0))[3] . "'\n"
    if($self->{"_debug"});

  if(defined $self->{"_array_processes"})
  {
    my $sbprc = undef;
    

    foreach $sbprc (@{$self->{"_array_processes"}})
    {
      #Clear all Sub Processes Errors too 
      $sbprc->clearErrors;
    } #foreach $sbprc (@{$self->{"_array_processes"}})
  } #if(defined $self->{"_array_processes"})  
    
  $self->{"_error_message"} = "";
  $self->{"_error_code"}    = 0;
}


#----------------------------------------------------------------------------
#Consultation Methods


sub getiProcess
{
	my $self = shift;
	my $rsprc = undef;
	my $iidx = shift;


  #Index must be a positive whole Number
	if($iidx =~ /^\d+$/)
	{
		if(defined $self->{"_array_processes"})
		{		
			if($iidx < scalar(@{$self->{"_array_processes"}}))
			{
				$rsprc = $self->{"_array_processes"}[$iidx];
			}
		}	#if(defined $self->{"_array_processes"})
	}	#if($iidx =~ /^\d+$/)


	return $rsprc;
}

sub getCheckInterval {
    my $self = shift;

    return $self->{"_check_interval"};
}

sub getProcessCount {
    my $self = shift;

    return scalar(@{$self->{"_array_processes"}});
}

sub getReportString {
    my $self = shift;

    return \$self->{"_report"};
}

sub getErrorCode {
    my $self = shift;

    return $self->{"_error_code"};
}

sub getErrorString {
    my $self = shift;

    return \$self->{"_error_message"};
}

sub isProfiling
{
  my $self = shift;

  return $self->{"_profiling"};
}


return 1;
