 #
 # Copyright © 2016, Varun Chitre "varun.chitre15" <varun.chitre15@gmail.com>
 # Copyright © 2016, Ayush Rathore "AyushR1" <ayushrathore12501@gmail.com>
 # If Anyone Use this Scrips Maintain Proper Credits
 #
 # This software is licensed under the terms of the GNU General Public
 # License version 2, as published by the Free Software Foundation, and
 # may be copied, distributed, and modified under those terms.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # Please maintain this if you use this script or any part of it
 #
 # Flex_Kernel  Build script
KERN_IMG=$PWD/arch/arm64/boot/Image
DTBTOOL=$PWD/tools/dtbToolCM
FINAL_KERNEL_ZIP=Flex_Kernel_$(date +"%d-%m-%Y")-tomato.zip
ZIP_MAKER_DIR=$PWD/anykernel
VERSION=7

BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

export CROSS_COMPILE="/mnt/home/chronos/toolchain/bin/aarch64-linux-android-"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Creator54"
export KBUILD_BUILD_HOST="Cloud"

compile_kernel ()
{
echo -e "$blue***********************************************"
echo "          Compiling Flex™ Kernel           "
echo -e "***********************************************$nocol"
rm -f $KERN_IMG
make lineageos_tomato_defconfig  -j$(nproc --all)
make Image -j$(nproc --all)
#make modules -j$(nproc --all)
make dtbs -j$(nproc --all)
if ! [ -a $KERN_IMG ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
$DTBTOOL -2 -o $PWD/arch/arm64/boot/dt.img -s 2048 -p $PWD/scripts/dtc/ $PWD/arch/arm/boot/dts/
}

case $1 in
clean)
make ARCH=arm64 -j4 clean mrproper
;;
dt)
make lineageos_tomato_defconfig -j$(nproc --all)
$DTBTOOL -2 -o $PWD/arch/arm64/boot/dt.img -s 2048 -p $PWD/scripts/dtc/ $PWD/arch/arm/boot/dts/
;;
*)
compile_kernel

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"

#ZIP MAKER time!
echo "**** Verifying ZIP MAKER Directory ****"
echo "**** Removing leftovers ****"
rm -rf $ZIP_MAKER_DIR/tools/dt.img
rm -rf $ZIP_MAKER_DIR/tools/Image
rm -rf $ZIP_MAKER_DIR/system/lib/modules/wlan.ko

echo "**** Copying Image ****"
cp $PWD/arch/arm64/boot/Image $ZIP_MAKER_DIR/tools/
echo "**** Copying dtb ****"
cp $PWD/arch/arm64/boot/dt.img $ZIP_MAKER_DIR/tools/
#echo "**** Copying modules ****"
cp $PWD/drivers/staging/prima/wlan.ko $ZIP_MAKER_DIR/system/lib/modules/

echo "**** Time to zip up! ****"
cd $ZIP_MAKER_DIR/
zip -r9 $FINAL_KERNEL_ZIP * -x $FINAL_KERNEL_ZIP
;;
esac

echo "**** Good Bye!! ****"
