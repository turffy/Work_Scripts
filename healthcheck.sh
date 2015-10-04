#!/bin/bash
# This script will do a quick check on CPU, Process, Disk Usage and Memory status.
# I got the idea from Yevhen Duma script.

echo "

####################################################################

Health Check Report (CPU,Process,Disk Usage, Memory)

####################################################################
"

#hostname command returns hostname
echo "Hostname : `hostname`"

#uname command with key -r returns Kernel version
echo "Kernel Version : `uname -r`"

#uptime command used to get uptime, and with sed command we cat process output to get only uptime.
echo -e "Uptime : `uptime | sed 's/.*up \([^,]*\), .*/\1/'`"

#who command is used to get last reboot time, awk for processing output
echo -e "Last Reboot Time : `who -b | awk '{print $3,$4}'`"

echo "*********************************************************************"

echo "
*********************************************************************

CPU Load - > Threshold < 1 Normal > 1 Caution , > 2 Unhealthy

*********************************************************************
"
#Check mpstat command is on the system
MPSTAT=`which mpstat`

#Get the exit code
MPSTAT=$?

#if exit status is not 0, this means mpstat not exist in system
if [ $MPSTAT != 0 ]

then
  
    echo "Please install mpstat!"
else

    #Check if lscpu installed
    LSCPU=`which lscpu`
    LSCPU=$?
    
    if [ $LSCPU != 0 ]
    
    then
        echo "RESULT=$RESULT" lscpu required to produce accurate results""
    
    else
        
        #if we have lscpu installed, we can get number of CPU's on our system and get statistic for each using mpstat command.
      
        cpus=`lscpu | grep -e "^CPU(s):" | cut -f2 -d: | awk '{print $1}'`
      
        i=0
    
        #here we make loop to get and print CPU usage statistic for each CPU.
        while [ $i -lt $cpus ]   
        do
            #here we get statistic for CPU and print it. Awk command help to do this, since output doesn't allow this to do with grep. AWK check if third value is equal to variable $i (it changes from 0 to number of CPU), and print %usr value for this CPU

             echo "CPU$i : `mpstat -P ALL | awk -v var=$i '{if($3 == var) print$4}'`"
             let i=$i+1
         done
    fi
  
fi

echo -e "Load Average: `uptime | awk -F'load average:' '{print $2}' | cut -f1 -d,`"

echo -e "Health Status: `uptime | awk -F'load average:' '{print $2}' | cut -f1 -d, | awk '{if($1 > 2) print "Unhealthy";else if ($1 > 1) print "Caution"; else print "Normal"}'`"

echo -e "

******************************************************************

Process

******************************************************************

Top memory using processs/application

PID %MEM RSS COMMAND

`ps aux | awk '{print $2, $4, $6, $11}' | sort -k3rn | head -n 10`

Top CPU using process/application

`top b -n1 | head -17 | tail -11`

**********************************************************************
"
echo -e "
**********************************************************************

Disk Usage - > Threshold < 90 Normal > 90% Caution > 95 Unhealthy

**********************************************************************
"
#we get disk usage with df command. -P key used to have postfix like output (there was problems with network shares, etc and -P resolve this problems). We print output to temp file to work with info more than one.
df -Pkh | grep -v 'Filesystem' > /tmp/df.status


echo -e "Filesystem Health Status"
echo

# We check the disk usage status.
while read DISK
do
    USAGE=`echo $DISK | awk '{print $5}' | cut -f1 -d%`
    if [ $USAGE -ge 90 ]
    then
        STATUS='Unhealthy'
    else
        STATUS='Normal'
    fi
    LINE=`echo $DISK| awk '{print $1,"\t",$6}'`
    echo -ne $LINE "\t\t" $STATUS
    echo
done < /tmp/df.status

echo
echo -e "Status"
echo

#Process the df.status.
while read DISK
do
    LINE=`echo $DISK | awk '{print $1,"\t",$6,"\t",$5,"used","\t",$4,"free space"}'`
echo -e $LINE
echo
done < /tmp/df.status

#Remove df.status file
rm /tmp/df.status

#here we get Total Memory, Used Memory, Free Memory, Used Swap and Free Swap values and save them to variables.
TOTALMEM=`free -m | head -2 | tail -1| awk '{print $2}'`
TOTALBC=`echo "scale=2;if($TOTALMEM<1024 && $TOTALMEM > 0) print 0;$TOTALMEM/1024"| bc -l`
USEDMEM=`free -m | head -2 | tail -1| awk '{print $3}'`
USEDBC=`echo "scale=2;if($USEDMEM<1024 && $USEDMEM > 0) print 0;$USEDMEM/1024"|bc -l`
FREEMEM=`free -m | head -2 | tail -1| awk '{print $4}'`
FREEBC=`echo "scale=2;if($FREEMEM<1024 && $FREEMEM > 0) print 0;$FREEMEM/1024"|bc -l`
TOTALSWAP=`free -m | tail -1| awk '{print $2}'`
TOTALSBC=`echo "scale=2;if($TOTALSWAP<1024 && $TOTALSWAP > 0) print 0;$TOTALSWAP/1024"| bc -l`
USEDSWAP=`free -m | tail -1| awk '{print $3}'`
USEDSBC=`echo "scale=2;if($USEDSWAP<1024 && $USEDSWAP > 0) print 0;$USEDSWAP/1024"|bc -l`
FREESWAP=`free -m |  tail -1| awk '{print $4}'`
FREESBC=`echo "scale=2;if($FREESWAP<1024 && $FREESWAP > 0) print 0;$FREESWAP/1024"|bc -l`

echo -e "
*********************************************************************
		     Memory 
*********************************************************************

=> Physical Memory

Total\tUsed\tFree\t%Free

${TOTALBC}GB\t${USEDBC}GB \t${FREEBC}GB\t$(($FREEMEM * 100 / $TOTALMEM  ))%

=> Swap Memory

Total\tUsed\tFree\t%Free

${TOTALSBC}GB\t${USEDSBC}GB\t${FREESBC}GB\t$(($FREESWAP * 100 / $TOTALSWAP  ))%

*********************************************************************
                     Hardware
*********************************************************************
`hplog -v`

"
