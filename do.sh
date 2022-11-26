#########################################################################
# File Name: do_linux.sh
# Author: SuWeishuai
# mail: suwsl@foxmail.com
# Created Time: Mon 16 May 2022 09:05:31 PM CST
# Version : 1.0
#########################################################################
#!/bin/bash

Env_arm32(){
    ARCH=arm
    CROSS_COMPILE=arm-linux-gnueabi-
    DEF_CONFIG=ok6410A_sdboot_updating_defconfig
    TARGET=uImage
    PLATFORM_SPECIFIC=
    GDB=gdb-multiarch
    GDB_SCRIPT=gdb_init
    GDB_ARCH=armv6
    LOAD_BASE=0x50008000
}

ShowEnv(){
    echo -e CROSS_COMPILE '\t' ${CROSS_COMPILE}
    echo -e DEF_CONFIG '\t' ${DEF_CONFIG}
    echo -e ARCH '\t' '\t' ${ARCH}
}

Simple(){

    # 1. checkout if build
    [ ! -e init/main.o ]  \
        && echo please build kernel first \
        && return

    Progress_bar_number=1
    progress_bar=`yes '#' | head -n ${Progress_bar_number} \
        | xargs | sed 's/ //g'`
    printf "[%-100s] %d%% \r" $progress_bar  $Progress_bar_number


    # 2. create dir for output
    PWD=`pwd`
    DIR_NAME=${PWD##*/}
    SIMPLE_SOURCE_DIR=../${DIR_NAME}_${ARCH}_simple
    [ -d ${SIMPLE_SOURCE_DIR} ] && rm ${SIMPLE_SOURCE_DIR} -rf
    mkdir ${SIMPLE_SOURCE_DIR}

    # 3. copy object file releated files to outout dir
    find . -name "*.o" | while read -r FILE_READ ; do
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
        [ -f ${OBJ_PATH}/.${OBJ_FILE}.cmd ] \
            && cp --parents ${OBJ_PATH}/.${OBJ_FILE}.cmd ${SIMPLE_SOURCE_DIR}

        # .xxx.o.cmd 文件中引用的include 文件
        [ -f ${OBJ_PATH}/.${OBJ_FILE}.cmd ] \
            && cat ${OBJ_PATH}/.${OBJ_FILE}.cmd \
            | grep -v "gcc \|wildcard \|source_fs\|deps_fs" \
            | awk -F " " '{print $1}' \
            |  sed '/^$/d' \
            | while read line
        do
            [ -f $line ] && cp $line --parents ${SIMPLE_SOURCE_DIR}
        done

    done

    Progress_bar_number=50
    progress_bar=`yes '#' | head -n ${Progress_bar_number} \
        | xargs | sed 's/ //g'`
    printf "[%-100s] %d%% \r" $progress_bar  $Progress_bar_number

    # 4. copy ko file releated files to outout dir
    #find . -name "*.ko" \
    #    | while read -r FILE_READ
    #do
    #    # .ko 文件
    #    cp --parents ${FILE_READ} ${SIMPLE_SOURCE_DIR}

    #    # .xxx.ko.cmd 文件
    #    OBJ_PATH=${FILE_READ%/*}
    #    OBJ_FILE=${FILE_READ##*/}
    #    cp --parents ${OBJ_PATH}/.${OBJ_FILE}.cmd ${SIMPLE_SOURCE_DIR}
    #done


    # 5. copy ko file releated files to outout dir
    find . -name modules.builtin -exec cp {} --parents ${SIMPLE_SOURCE_DIR} \;
    find . -name modules.order   -exec cp {} --parents ${SIMPLE_SOURCE_DIR} \;

    # 6. copy Kbuild file releated files to outout dir
    # Makefile  Kbuild  Kconfig
    find . -name Kconfig -or -name Kbuild  -or -name Makefile -type f \
        | while read -r FILE_READ
    do
        FILE_PATH=${FILE_READ%/*}
        [ -d ${SIMPLE_SOURCE_DIR}/${FILE_PATH} ] \
            && cp ${FILE_READ} ${SIMPLE_SOURCE_DIR}/${FILE_PATH}
    done

    Progress_bar_number=90
    progress_bar=`yes '#' | head -n ${Progress_bar_number} \
        | xargs | sed 's/ //g'`
    printf "[%-100s] %d%% \r" $progress_bar  $Progress_bar_number


    # 7. copy other releated files to outout dir
    # 其他重要文件
    FILE_ISSUE=" vmlinux System.map "
    FILE_ISSUE+=" .config "
    FILE_ISSUE+=" .missing-syscalls.d "
    FILE_ISSUE+=" .tmp_System.map .tmp_kallsyms1.S .tmp_kallsyms2.S "
    FILE_ISSUE+=" .tmp_vmlinux1 .tmp_vmlinux2 "
    FILE_ISSUE+=" .version Module.symvers "
    FILE_ISSUE+=" arch/${ARCH}/kernel/asm-offsets.s "
    FILE_ISSUE+=" include/linux/version.h "
    FILE_ISSUE+=" kernel/bounds.s "
    FILE_ISSUE+=" usr/.initramfs_data.cpio.d "
    FILE_ISSUE+=" log_config log_build log_run"

    for file in ${FILE_ISSUE};do
        [ -f ${file} ] && cp ${file} ${SIMPLE_SOURCE_DIR} --parents
    done

    # 8. copy other releated dirs to outout dir
    # 其他重要目录
    DIR_ISSUE="include "
    DIR_ISSUE+="include/config "
    DIR_ISSUE+="include/generated "
    DIR_ISSUE+=".tmp_versions "
    DIR_ISSUE+="arch/${ARCH}/include "

    for dir in ${DIR_ISSUE};do
        [ -d ${dir} ] && cp ${dir} ${SIMPLE_SOURCE_DIR} --parents -r
    done

    # 9. show outout dir
    echo simple code is in ${SIMPLE_SOURCE_DIR}
}

Simple_with_log(){
    [ -f log_simple ] && mv log_simple log_simple_bak

    PWD=`pwd`
    DIR_NAME=${PWD##*/}
    SIMPLE_SOURCE_DIR=../${DIR_NAME}_${ARCH}_simple

    Simple 2>&1 | tee -a  log_simple

    cp log_simple ${SIMPLE_SOURCE_DIR}
}

ShowConfig(){
    echo
    ls arch/${ARCH}/configs/ok6410A* | \
        xargs -n 1 | \
        awk -F '/' '{print $4}'
    echo
}

Config(){
    if [ $# -eq 0 ];then
        :
    elif [ $# -eq 1  ];then
        DEF_CONFIG=$1
    else
        echo func  :${FUNCNAME}
        echo argc  :$#
        let i=0
        while [ $# != 0 ]
        do
            echo -e argv[${i}] $1
            let i=i+1
            shift
        done

        echo not supported
        return
    fi

    echo CONFIG is ${DEF_CONFIG}
    [ ! -f arch/${ARCH}/configs/${DEF_CONFIG} ] && \
        echo arch/${ARCH}/configs/${DEF_CONFIG} not exist && ShowConfig && return

    sleep 1
    [ -f log_config ] && mv log_config log_config_bak
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} ${DEF_CONFIG} 2>&1 \
        | tee -a  log_config

}

Build(){

    [ -f log_build ] && mv log_build log_build_bak

    CPU_NM=`cat /proc/cpuinfo  |grep processor | wc -l`
    let cpu_power=${CPU_NM}*3/5
    [ ${cpu_power} -lt 1 ] && let cpu_power=1

    make ${TARGET} \
        ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} \
        LOADADDR=${LOAD_BASE} \
        V=1 \
        2>&1 | tee -a  log_build

    [ -f arch/${ARCH}/boot/uImage ] && cp arch/${ARCH}/boot/uImage  /srv/tftp/
}

Setup(){
    [ -f arch/${ARCH}/boot/uImage ] && cp arch/${ARCH}/boot/uImage  /srv/tftp/
}

Debug_gdb(){
    [ -f log_run ]     && mv log_run     log_run_bak
    [ -f log_gdb.txt ] && mv log_gdb.txt log_gdb_bak.txt

    [ ! -f gdb_init  ] && Gen_gdbinit

    ${GDB} -x ${GDB_SCRIPT} -tui
}

Gen_gdbinit(){
    echo "set logging file log_gdb.txt" >  ${GDB_SCRIPT}
    echo "set logging on"               >> ${GDB_SCRIPT}
    echo "set architecture ${GDB_ARCH}" >> ${GDB_SCRIPT}
    echo "target remote localhost:1234" >> ${GDB_SCRIPT}

    head_text=`${CROSS_COMPILE}readelf -S vmlinux   |grep -w "\.head.text"  | awk -F "]" '{print $2}' | awk -F " " '{print $3}' | tr "[a-f]" "[A-F]" `
    text=`     ${CROSS_COMPILE}readelf -S vmlinux   |grep -w "\.text"       | awk -F "]" '{print $2}' | awk -F " " '{print $3}' | tr "[a-f]" "[A-F]" `
    rodata=`   ${CROSS_COMPILE}readelf -S vmlinux   |grep -w "\.rodata"     | awk -F "]" '{print $2}' | awk -F " " '{print $3}' | tr "[a-f]" "[A-F]" `
    init_text=`${CROSS_COMPILE}readelf -S vmlinux   |grep -w "\.init.text"  | awk -F "]" '{print $2}' | awk -F " " '{print $3}' | tr "[a-f]" "[A-F]" `
    init_data=`${CROSS_COMPILE}readelf -S vmlinux   |grep -w "\.init.data"  | awk -F "]" '{print $2}' | awk -F " " '{print $3}' | tr "[a-f]" "[A-F]" `
    echo head_text  ${head_text}
    echo text       ${text}
    echo rodata     ${rodata}
    echo init_text  ${init_text}
    echo init_data  ${init_data}


    offset=`echo "obase=16;ibase=16;${head_text}-${LOAD_BASE}"|bc`
    echo offset     ${offset}

    recipe_head_text=`echo "obase=16;ibase=16;${head_text}-${offset}"|bc`
    recipe_init_text=`echo "obase=16;ibase=16;${init_text}-${offset}"|bc`
    recipe_rodata=`   echo "obase=16;ibase=16;${rodata}   -${offset}"|bc`
    recipe_text=`     echo "obase=16;ibase=16;${text}     -${offset}"|bc`
    recipe_init_data=`echo "obase=16;ibase=16;${init_data}-${offset}"|bc`

    echo recipe_head_text   ${recipe_head_text}
    echo recipe_text        ${recipe_text}
    echo recipe_rodata      ${recipe_rodata}
    echo recipe_init_text   ${recipe_init_text}
    echo recipe_init_data   ${recipe_init_data}
    echo "add-symbol-file vmlinux -s .text 0X${recipe_text} -s .head.text 0X${recipe_head_text} -s .rodata 0X${recipe_rodata} -s .init.text 0X${recipe_init_text} -s .init.data 0X${recipe_init_data}" >> ${GDB_SCRIPT}
    echo "b *0x${LOAD_BASE}" >> ${GDB_SCRIPT}

}

Clean(){
    make mrproper
}

##########################################################
##########################################################


Usage(){
    echo Note  :
    echo -e '\t' Please put this script in the top-level directory of Linux ,Then run it
    echo Usage :
    cat ${CURRENT_SCRIPT}               \
        | grep "(){"                    \
        | grep -v "^ "                  \
        | egrep -v  "Usage|Main"        \
        | grep  Env_                    \
        | while read line
    do
        ENV_NAME=`echo $line | awk -F "_" '{print $2}'\
            | awk -F "(" '{print $1}'`

        cat ${CURRENT_SCRIPT}           \
            | grep "(){"                \
            | grep -v "^ "              \
            | egrep -v  "Usage|Main"    \
            | awk -F "(" '{print $1}'   \
            | grep -v Env_              \
            | while read line
         do
            FUNCTION=$line
            echo -e '\t' ENV=${ENV_NAME} ${CURRENT_SCRIPT} ${FUNCTION}
         done
         echo
    done
    exit -1
}

Main(){

    CURRENT_SCRIPT=$0
    OBJ=$1

    if [ $# == 0 ] || [ -z ${ENV} ];then
        Usage
    fi

    cat ${CURRENT_SCRIPT}               \
        | grep "(){"                    \
        | grep -v "^ "                  \
        | egrep -v  "Usage|Main"        \
        | grep -w Env_${ENV} > /dev/null
    if [ $? -eq 0 ];then
        Env_${ENV}
    else
        Usage
    fi

    [ ${OBJ} == help ] && Usage

    cat ${CURRENT_SCRIPT}               \
        | grep "(){"                    \
        | grep -v "^ "                  \
        | egrep -v  "Usage|Main"        \
        | grep -w ${OBJ} > /dev/null
    if [ $? -eq 0 ];then
        shift
        start_time=$(date +%s)
        ${OBJ} $*
        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "cost time is $(($cost_time/60))min $(($cost_time%60))s"
    else
        echo ${OBJ} : NOT DEFINED
        Usage
    fi
}

Main $*
