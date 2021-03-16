#########################################################################
# File Name: config.sh
# Author: Sues
# mail: sumory.kaka@foxmail.com
# Created Time: Tue 22 Sep 2020 11:21:28 AM CST
# Version : 1.0
#########################################################################
#!/bin/bash
#make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- forlinx6410_systemd_defconfig
#make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- forlinx6410_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- ok6410A_sdboot_mini_defconfig 2>&1 | tee -a  log_config
#make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- s3c6400_defconfig 2>&1 | tee -a  log_config

#$ arm-linux-gnueabi-gcc -v 
#Using built-in specs.
#COLLECT_GCC=arm-linux-gnueabi-gcc
#COLLECT_LTO_WRAPPER=/home/suws/ok6410/system-new/toolchain/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabi/bin/../libexec/gcc/arm-linux-gnueabi/7.4.1/lto-wrapper
#Target: arm-linux-gnueabi
#Configured with: '/home/tcwg-buildslave/workspace/tcwg-make-release_0/snapshots/gcc.git~linaro-7.4-2019.02/configure' SHELL=/bin/bash --with-mpc=/home/tcwg-buildslave/workspace/tcwg-make-release_0/_build/builds/destdir/x86_64-unknown-linux-gnu --with-mpfr=/home/tcwg-buildslave/workspace/tcwg-make-release_0/_build/builds/destdir/x86_64-unknown-linux-gnu --with-gmp=/home/tcwg-buildslave/workspace/tcwg-make-release_0/_build/builds/destdir/x86_64-unknown-linux-gnu --with-gnu-as --with-gnu-ld --disable-libmudflap --enable-lto --enable-shared --without-included-gettext --enable-nls --with-system-zlib --disable-sjlj-exceptions --enable-gnu-unique-object --enable-linker-build-id --disable-libstdcxx-pch --enable-c99 --enable-clocale=gnu --enable-libstdcxx-debug --enable-long-long --with-cloog=no --with-ppl=no --with-isl=no --disable-multilib --with-float=soft --with-mode=thumb --with-tune=cortex-a9 --with-arch=armv7-a --enable-threads=posix --enable-multiarch --enable-libstdcxx-time=yes --enable-gnu-indirect-function --with-build-sysroot=/home/tcwg-buildslave/workspace/tcwg-make-release_0/_build/sysroots/arm-linux-gnueabi --with-sysroot=/home/tcwg-buildslave/workspace/tcwg-make-release_0/_build/builds/destdir/x86_64-unknown-linux-gnu/arm-linux-gnueabi/libc --enable-checking=release --disable-bootstrap --enable-languages=c,c++,fortran,lto --build=x86_64-unknown-linux-gnu --host=x86_64-unknown-linux-gnu --target=arm-linux-gnueabi --prefix=/home/tcwg-buildslave/workspace/tcwg-make-release_0/_build/builds/destdir/x86_64-unknown-linux-gnu
#Thread model: posix
#gcc version 7.4.1 20181213 [linaro-7.4-2019.02 revision 56ec6f6b99cc167ff0c2f8e1a2eed33b1edc85d4] (Linaro GCC 7.4-2019.02)
