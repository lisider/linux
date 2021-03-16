#########################################################################
# File Name: build.sh
# Author: Sues
# mail: sumory.kaka@foxmail.com
# Created Time: Tue 22 Sep 2020 11:21:34 AM CST
# Version : 1.0
#########################################################################
#!/bin/bash
#[ -f log_build  ] && rm log_build
#make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- LOADADDR=0x50008000 uImage V=1 2>&1 | tee -a  log_build2
#make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-  uImage V=1 2>&1 | tee -a  log_build
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- uImage V=1 2>&1 | tee -a  log_build

#ifconfig eth0  10.10.11.117 netmask 255.255.255.0  up

#route add default gw 10.10.11.254
