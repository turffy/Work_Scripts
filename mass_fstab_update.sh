#!/sbin/sh
#
###################################################################################################
#Name: mass_fstab_update.sh
#Purpose: The Script will backup the rtcis and das fstab then will append additional mount point
#         stated on the script sed -i
#Date: 2015.04.28
#Author: Ac Perdon
#Change:
#       2015.04.28 - Initial
#
#
####################################################################################################

list=$1

if [ -z "$list" ];then
    echo ""
    echo " Usage: ./mass_fstab_update.sh <Server list> "
    echo " Example: ./mass_fstab_update.sh serv_list "
    echo ""
    exit
fi

for i in $(cat $list);do
  echo "================================================================"
  echo "Doing a backup for fstab.das and fstab.rtcis on $i"
  ssh $i cp -p  /usr/local/DT/fstab.das  /usr/local/DT/fstab.das.T01189088_20150404.bak
  ssh $i cp -p /usr/local/DT/fstab.rtcis /usr/local/DT/fstab.rtcis.T01189088_20150404.bak

  echo '\n'
  echo "Updating the fstab.das on $i"

  line_count=`ssh $i grep -n "swap" /usr/local/DT/fstab.das | cut -d: -f1`
  second_ln=$((line_count + 1))
  next_line=$((second_ln + 1))
  ssh $i sed -i  "${second_ln}i\ '/dev/vg00/lv_perf       /opt/perf               ext3    defaults        1 2'" /usr/local/DT/fstab.das
  ssh $i sed -i  "${next_line}i\ '/dev/vg00/lv_vperf      /var/opt/perf           ext3    defaults        1 2'" /usr/local/DT/fstab.das


  echo '\n'
  echo "Updating the fstab.rtcis on $i"

  line_count=`ssh $i grep -n "swap" /usr/local/DT/fstab.rtcis | cut -d: -f1`
  second_ln=$((line_count + 1))
  next_line=$((second_ln + 1))
  ssh $i sed -i  "${second_ln}i\ '/dev/vg00/lv_perf       /opt/perf               ext3    defaults        1 2'" /usr/local/DT/fstab.rtcis
  ssh $i sed -i  "${next_line}i\ '/dev/vg00/lv_vperf      /var/opt/perf           ext3    defaults        1 2'" /usr/local/DT/fstab.rtcis
done
exit

