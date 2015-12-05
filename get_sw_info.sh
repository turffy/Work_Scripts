#!/sbin/sh
# This script will read on a file that has the server name and nic
# and will do ssh and get the switch info where the nic is connected.
# Author: AC 06-Dec-15
###################################################################

cat test | while read line;do
  serv=$(echo $line | awk '{print $1}')
  nic=$(echo $line | awk '{print $2}')

  echo $serv
  ssh -n $serv tcpdump -nn -v -i $nic -s 1500 -c 1 'ether[20:2] == 0x2000' | grep -E 'Device-ID|Port-ID'
  echo ""
  sleep 2
done

