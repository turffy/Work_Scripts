#!/bin/sh

for i in `cat /home/ct7825/WORKSPACE/dfmonserv_list`;do
    echo " Backup df_mon.cfg on $i .........."
    ssh $i "cp -p /var/opt/OV/conf/OpC/df_mon.cfg /var/opt/OV/conf/OpC/df_mon.cfg_T01374669_20151202"
    echo " Updating df_mon.cfg on $i........"
    line_count=`ssh $i "grep -wn 'end of df_mon.cfg' /var/opt/OV/conf/OpC/df_mon.cfg | cut -d: -f1"`
    before_ln=$((line_count - 1))
    ssh $i sed -i  "${before_ln}i\ '##Entries for inode monitoring\n''*  - 75 major ; LINUX\n''*  - 80 critical ; LINUX'" /var/opt/OV/conf/OpC/df_mon.cfg
    sleep 2
done
