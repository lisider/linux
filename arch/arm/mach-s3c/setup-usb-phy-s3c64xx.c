// SPDX-License-Identifier: GPL-2.0+
//
// Copyright (C) 2011 Samsung Electronics Co.Ltd
// Author: Joonyoung Shim <jy0922.shim@samsung.com>

#include <linux/clk.h>
#include <linux/delay.h>
#include <linux/err.h>
#include <linux/io.h>
#include <linux/platform_device.h>
#include "map.h"
#include "cpu.h"
#include "usb-phy.h"

#include "regs-sys-s3c64xx.h"
#include "regs-usb-hsotg-phy-s3c64xx.h"

enum samsung_usb_phy_type {
	USB_PHY_TYPE_DEVICE,
	USB_PHY_TYPE_HOST,
};

static int s3c_usb_otgphy_init(struct platform_device *pdev)
{
	struct clk *xusbxti;
	u32 phyclk;

    // STEP1
    // 强制要求,必须做
    // PA : 0x7E00_F900 VA :0xF6000000 + 0x00100000 + 0x900
    // USB signal mask to prevent unwanted leakage.
    // This bit must set before USB PHY is used.
	writel(readl(S3C64XX_OTHERS) | S3C64XX_OTHERS_USBMASK, S3C64XX_OTHERS);

    // STEP2
    // PA : 0x7C10_0004 VA :0xF6000000 + 0x00500000 + 0x00200000 + 0x4
    // Reference Clock Frequency Select for PLL
	/* set clock frequency for PLL */
	phyclk = readl(S3C_PHYCLK) & ~S3C_PHYCLK_CLKSEL_MASK;

    // 48MHz From external AD7 & AD8
	xusbxti = clk_get(&pdev->dev, "xusbxti");
	if (!IS_ERR(xusbxti)) {
		switch (clk_get_rate(xusbxti)) {
		case 12 * MHZ:
			phyclk |= S3C_PHYCLK_CLKSEL_12M;
			break;
		case 24 * MHZ:
			phyclk |= S3C_PHYCLK_CLKSEL_24M;
			break;
		default:
		case 48 * MHZ: // IN
			/* default reference clock */
			break;
		}
		clk_put(xusbxti);
	}

    // 将外面接的时钟频率信息 设置 OPHYCLK , 这个时钟供给给 两个 PHY
    // 48MHz clock on clk48m_ohci is available at all times, even in Suspend mode.
	/* TODO: select external clock/oscillator */
	writel(phyclk | S3C_PHYCLK_CLK_FORCE, S3C_PHYCLK);


    // STEP3
    // 相当于 打开了 USB 2.0 的 PHY 和 USB 1.0 的 PHY, 并设置 suepend 不断电
    // PA :0x7C10_0000 VA : 0xF6000000 + 0x00500000 + 0x00200000 + 0x0
    // Apply Suspend signal for power save : disable ( Normal Operation )
    // Analog block power down in PHY2.0 : Analog block power up (Normal Operation)     // USB 1.1 Transceiver UP
    // OTG block power down in PHY2.0 : OTG block power up                              // USB 2.0 OTG PHY UP , 这个为1 也可,毕竟现在只用USB host,不用USB otg
	/* set to normal OTG PHY */
	writel((readl(S3C_PHYPWR) & ~S3C_PHYPWR_NORMAL_MASK), S3C_PHYPWR);
	mdelay(1);

    // STEP4
    // 复位 两个phy
    // PA :0x7C10_0008 VA : 0xF6000000 + 0x00500000 + 0x00200000 + 0x8
    // OTG PHY 2.0 S/W Reset
    // OTG Link Core hclk domain S/W Reset
    // OTG Link Core phy_clock domain S/W Reset
	/* reset OTG PHY and Link */
	writel(S3C_RSTCON_PHY | S3C_RSTCON_HCLK | S3C_RSTCON_PHYCLK,
			S3C_RSTCON);
	udelay(20);	/* at-least 10uS */
	writel(0, S3C_RSTCON);

	return 0;
}

static int s3c_usb_otgphy_exit(struct platform_device *pdev)
{
	writel((readl(S3C_PHYPWR) | S3C_PHYPWR_ANALOG_POWERDOWN |
				S3C_PHYPWR_OTG_DISABLE), S3C_PHYPWR);

	writel(readl(S3C64XX_OTHERS) & ~S3C64XX_OTHERS_USBMASK, S3C64XX_OTHERS);

	return 0;
}

int s3c_usb_phy_init(struct platform_device *pdev, int type)
{
	if (type == USB_PHY_TYPE_DEVICE)
		return s3c_usb_otgphy_init(pdev);

	return -EINVAL;
}

int s3c_usb_phy_exit(struct platform_device *pdev, int type)
{
	if (type == USB_PHY_TYPE_DEVICE)
		return s3c_usb_otgphy_exit(pdev);

	return -EINVAL;
}
