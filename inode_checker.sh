#!/bin/bash
#This will check Inode threshold if its 75% major or 80% critical.
df -PiH | grep -vE '^Filesystem|tmpfs|s.bin' | awk '{print $5 " " $6}'  | while read output;
do
    #echo $output
        inode_count=$(echo $output | awk '{ print $1}' | cut -d'%' -f1)
        partition=$(echo $output | awk '{ print $2 }' )
        if [ $inode_count -ge 75 ] || [ $inode_count -ge 80 ];then
            echo "Inode is High on \"$partition ($inode_count%)\""
        fi
done
