#########################################################################
# File Name: do.sh
# Author: Sues
# mail: sumory.kaka@foxmail.com
# Created Time: Tue 01 Sep 2020 12:15:58 PM CST
# Version : 1.0
#########################################################################
#!/bin/bash

function checkOutSimpleCode {

    PWD=`pwd`
    DIR_NAME=${PWD##*/}
    #echo DIR_NAME:${DIR_NAME}
    SIMPLE_SOURCE_DIR=../${DIR_NAME}_simple
    [ -d ${SIMPLE_SOURCE_DIR} ] && rm ${SIMPLE_SOURCE_DIR} -rf
    mkdir ${SIMPLE_SOURCE_DIR}

    find . -name "*.o" | while read -r FILE_READ ; do
        # echo $FILE_READ

        # .o 文件
        #cp --parents ${FILE_READ} ${SIMPLE_SOURCE_DIR}

        # .s .S .c 文件
        [ -e ${FILE_READ%.*}.c  ] && FILE=${FILE_READ%.*}.c
        [ -e ${FILE_READ%.*}.s ] && FILE=${FILE_READ%.*}.s
        [ -e ${FILE_READ%.*}.S  ] && FILE=${FILE_READ%.*}.S
        cp --parents ${FILE} ${SIMPLE_SOURCE_DIR}

        # .xxx.o.cmd 文件
        OBJ_PATH=${FILE_READ%/*}
        OBJ_FILE=${FILE_READ##*/}
        [ -f ${OBJ_PATH}/.${OBJ_FILE}.cmd ] && cp --parents ${OBJ_PATH}/.${OBJ_FILE}.cmd ${SIMPLE_SOURCE_DIR}

        [ -f ${OBJ_PATH}/.${OBJ_FILE}.cmd ] && cat ${OBJ_PATH}/.${OBJ_FILE}.cmd  | grep -v "gcc \|wildcard \|source_fs\|deps_fs" | awk -F " " '{print $1}' |  sed '/^$/d' | while read line
        do
            [ -f $line ] && cp $line --parents ${SIMPLE_SOURCE_DIR}
        done

    done

    find . -name "*.ko" | while read -r FILE_READ ; do
        # echo $FILE_READ

        # .ko 文件
        cp --parents ${FILE_READ} ${SIMPLE_SOURCE_DIR}

        # .xxx.ko.cmd 文件
        OBJ_PATH=${FILE_READ%/*}
        OBJ_FILE=${FILE_READ##*/}
        cp --parents ${OBJ_PATH}/.${OBJ_FILE}.cmd ${SIMPLE_SOURCE_DIR}
    done


    find . -name modules.builtin -exec cp {} --parents ${SIMPLE_SOURCE_DIR} \;
    find . -name modules.order   -exec cp {} --parents ${SIMPLE_SOURCE_DIR} \;

    # Makefile  Kbuild  Kconfig
    find . -name Kconfig -or -name Kbuild  -or -name Makefile -type f | while read -r FILE_READ ; do
        FILE_PATH=${FILE_READ%/*}
        [ -d ${SIMPLE_SOURCE_DIR}/${FILE_PATH} ] && cp ${FILE_READ} ${SIMPLE_SOURCE_DIR}/${FILE_PATH}
    done



    # 其他重要文件
    FILE_ISSUE=" vmlinux System.map "
    FILE_ISSUE+=" .config "
    FILE_ISSUE+=" .missing-syscalls.d .tmp_System.map .tmp_kallsyms1.S .tmp_kallsyms2.S .tmp_vmlinux1 .tmp_vmlinux2 .version Module.symvers arch/arm/kernel/asm-offsets.s arch/arm/lib/lib.a include/linux/version.h kernel/bounds.s lib/lib.a usr/.initramfs_data.cpio.d "

    for file in ${FILE_ISSUE};do
        [ -f ${file} ] && cp ${file} ${SIMPLE_SOURCE_DIR} --parents
    done

    # 其他重要目录

    DIR_ISSUE="include "
    DIR_ISSUE+="include/config "
    DIR_ISSUE+="include/generated "
    DIR_ISSUE+=".tmp_versions "
    DIR_ISSUE+="arch/arm/include "

    for dir in ${DIR_ISSUE};do
        [ -d ${dir} ] && cp ${dir} ${SIMPLE_SOURCE_DIR} --parents -r
    done

    echo simple code is in ${SIMPLE_SOURCE_DIR}

}

function Main {

    [ $# -ne 1 ] && echo usage : ./do.sh xxx && exit -1

    CPU_NM=`cat /proc/cpuinfo  |grep processor | wc -l`
    let cpu_power=${CPU_NM}*3/5
    [ ${cpu_power} -lt 1 ] && let cpu_power=1

    start_time=$(date +%s)

    if [ $1 == config ];then
		[ -f log_config ] && rm log_config
        #make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- ok6410A_sdboot_mini_net_lcd_x11_usb_debug_uvc_defconfig 2>&1 | tee -a  log_config
        make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- ok6410A_sdboot_mini_net_lcd_x11_usb_debug_defconfig 2>&1 | tee -a  log_config
    elif [ $1 == build ];then
		[ -f log_build ] && mv log_build log_build_bak
        make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-  LOADADDR=0x50008000 uImage V=1 2>&1 | tee -a  log_build 
		[ -f arch/arm/boot/uImage ] && cp arch/arm/boot/uImage  /var/lib/tftpboot/
    elif [ $1 == clean ];then
        make mrproper
    elif [ $1 == simple ];then
        [ ! -e init/main.o ] && echo please build kernel first && exit -2
        checkOutSimpleCode
    else
        echo ${1} is not supported
    fi

    end_time=$(date +%s)
    cost_time=$[ $end_time-$start_time ]
    echo "cost time is $(($cost_time/60))min $(($cost_time%60))s"

}

Main $*
