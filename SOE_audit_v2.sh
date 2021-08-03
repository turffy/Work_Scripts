#!/bin/bash
killqueryform(){
  echo "ps -efw | grep "rpm -qa --queryformat %{NAME}|%{VENDOR}|%{EPOCH}:%{VERSION}-%{RELEASE}|%{ARCH}|%{SUMMARY}" | grep -v grep | awk '{print $2}' | xargs kill"
}

VAL(){
   echo "($(date +%s)-$(rpm -q --queryformat "%{INSTALLTIME}\n" VALIDATION | sort -u))/60/60/24" | bc
}

UTIL(){
   echo "($(date +%s)-$(rpm -q --queryformat "%{INSTALLTIME}\n" SOEG_UTIL | sort -u))/60/60/24" | bc
}

SYS(){
   echo "($(date +%s)-$(rpm -q --queryformat "%{INSTALLTIME}\n" SOEG_SYS | sort -u))/60/60/24" | bc
}


list=$1
for i in $(cat $list)
do
  ssh -o "BatchMode=yes" -o ConnectTimeout=5 -o ConnectionAttempts=1 -o StrictHostKeyChecking=no $i "sudo bash -c '$(declare -f killqueryform); killqueryform '" 2> /dev/null
  soe_val=$(ssh -o "BatchMode=yes" -o ConnectTimeout=5 -o ConnectionAttempts=1 -o StrictHostKeyChecking=no $i "sudo bash -c '$(declare -f VAL); VAL '" 2> /dev/null)
  soe_util=$(ssh -o "BatchMode=yes" -o ConnectTimeout=5 -o ConnectionAttempts=1 -o StrictHostKeyChecking=no $i "sudo bash -c '$(declare -f UTIL); UTIL '" 2> /dev/null)
  soe_sys=$(ssh -o "BatchMode=yes" -o ConnectTimeout=5 -o ConnectionAttempts=1 -o StrictHostKeyChecking=no $i "sudo bash -c '$(declare -f SYS); SYS '" 2> /dev/null)

  if [ -n "$soe_val" -a -n "$soe_util" -a -n "$soe_sys" ];then
     if [ $soe_val -lt 5  -a  $soe_util -lt 5 -a $soe_sys -lt 5 ];then
        echo "$i SOE_Updated!"
     else
        echo "$i SOE_Not_updated!"
    fi
  else
    #echo "" | awk '!/^$/'
    echo "$i possible_not_accessible"
  fi
done
