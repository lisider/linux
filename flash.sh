#########################################################################
# File Name: flash.sh
# Author: Sues
# mail: sumory.kaka@foxmail.com
# Created Time: Fri 12 Mar 2021 09:53:31 AM CST
# Version : 1.0
#########################################################################
#!/bin/bash
[ ! -f arch/arm/boot/uImage ] && echo "arch/arm/boot/uImage not exist" && exit -2
[ ! -e /dev/sdb1 ] && echo "/dev/sdb1 not exist" && exit -2
sudo mount /dev/sdb1 /mnt
sudo cp arch/arm/boot/uImage /mnt
sudo umount /mnt
