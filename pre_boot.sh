#!/bin/bash
#Author: Ac Perdon
#Date: 2015.09.01
#Purpose: Pre-Work for System Re-boot
#Change: Initial

echo "
####################################################################
Pre Work before re-boot the server.
####################################################################

Hostname : `hostname`

Product Name: `dmidecode | grep "Product Name" | cut -d: -f2`

Firmware Version: `dmidecode | grep -i release  |cut -d: -f2`

OS Version: `cat /etc/redhat-release`

Machine Type: `uname -m`

Kernel Version : `uname -r`

Uptime : `uptime | sed 's/.*up \([^,]*\), .*/\1/'`

Date: `date`

Time Zone: `ls -l /etc/localtime | awk '{print $11}'`

####################################################################
                        Disk info
####################################################################

Volume Group

`vgs`


Logical Volume

`lvs`

Physical Volume

`pvs`

Number of mounted FS: `mount | wc -l`

Actual Filesystem:

`df -h`

SBDF

`/opt/soeg/bin/sbdf.sh`

FDISK

`fdisk -l`



####################################################################
                       Kernel Paramter
####################################################################

`cat /etc/sysctl.conf`


####################################################################
                       Network Info
####################################################################

NIC

`ifconfig -a`


GATWAY

`netstat -rn`



####################################################################
                       Swap Info
####################################################################

`cat /proc/swaps`


####################################################################
                       Hardware Info
####################################################################

`/usr/sbin/hpacucli ctrl all show config`


####################################################################
                       Other Info
####################################################################


Etrust status
`/usr/seos/bin/issec`


RPMs installed: Please refer to /root/rpm.out
`rpm -aq > /root/rpm.out 2>&1`

NFS mounts

`showmount -a`

"

