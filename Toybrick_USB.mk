JOB=`nproc`
DTB=rk3399pro-toybrick-prod-linux
TKCC=../toolchains/aarch64/bin/aarch64-linux-gnu-


function make_extlinux_conf()
{
    echo "label rockchip-kernel-4.4" > boot_linux/extlinux/extlinux.conf
    echo "  kernel /extlinux/Image" >> boot_linux/extlinux/extlinux.conf
    echo "  fdt /extlinux/toybrick.dtb" >> boot_linux/extlinux/extlinux.conf
    echo "  append  earlycon=uart8250,mmio32,0xff1a0000 initrd=/initramfs-toybrick-${VERSION}.img root=PARTUUID=614e0000-0000-4b53-8000-1d28000054a9 rw rootwait rootfstype=ext4" >> boot_linux/extlinux/extlinux.conf
}

rm -rf ../kernel/boot_linux
mkdir -p ../kernel/boot_linux/extlinux

make -C ../kernel/ rockchip_linux_defconfig

make -C ../kernel/ ARCH=arm64 ${DTB}-edp.img CROSS_COMPILE=${TKCC} -j${JOB}
make -C ../kernel/ ARCH=arm64 ${DTB}-mipi.img CROSS_COMPILE=${TKCC} -j${JOB}
cp -f ../kernel/arch/arm64/boot/dts/rockchip/${DTB}-edp.dtb ../kernel/boot_linux/extlinux/toybrick-edp.dtb
cp -f ../kernel/arch/arm64/boot/dts/rockchip/${DTB}-mipi.dtb ../kernel/boot_linux/extlinux/toybrick-mipi.dtb

make -C ../kernel/ ARCH=arm64 ${DTB}.img CROSS_COMPILE=${TKCC} -j${JOB}

cp -f ../kernel/arch/arm64/boot/dts/rockchip/${DTB}.dtb ../kernel/boot_linux/extlinux/toybrick.dtb
cp -f ../kernel/arch/arm64/boot/dts/rockchip/${DTB}.dtb ../kernel/boot_linux/extlinux/toybrick-default.dtb
cp -f ../kernel/arch/arm64/boot/Image ../kernel/boot_linux/extlinux/
make_extlinux_conf
cp -f initramfs-toybrick-${VERSION}.img boot_linux/
cp -f rescue.sh boot_linux/
if [ "`uname -i`" == "aarch64" ]; then
    echo y | mke2fs -b 4096 -d boot_linux -i 8192 -t ext2 boot_linux.img $((64 * 1024 * 1024 / 4096))
else
    genext2fs -b 32768 -B $((64 * 1024 * 1024 / 32768)) -d boot_linux -i 8192 -U boot_linux.img
fi


