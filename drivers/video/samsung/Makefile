#
# Makefile for the s3c framebuffer driver
#

obj-$(CONFIG_FB_S3C_EXT)		+= s3cfb.o
obj-$(CONFIG_ARCH_S3C64XX)		+= s3cfb_fimd4x.o

obj-${CONFIG_LCD_WXCAT43}		+= wxcat43.o

CFLAGS_s3cfb.o := -Iarch/arm/mach-s3c -Iarch/arm/mach-s3c/include
CFLAGS_s3cfb_fimd4x.o := -Iarch/arm/mach-s3c -Iarch/arm/mach-s3c/include
CFLAGS_wxcat43.o := -Iarch/arm/mach-s3c -Iarch/arm/mach-s3c/include
