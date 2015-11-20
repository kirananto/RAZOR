 #
 # Copyright © 2015, KiranAnto
 #
 # Custom build script
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
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/arch/arm/boot/Image
MODULES_DIR=$KERNEL_DIR/RaZORBUILDOUTPUT/Common
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
# Modify the following variable if you want to build
export CROSS_COMPILE="$KERNEL_DIR/../../Toolchains/arm-eabi-5.2/bin/arm-eabi-"
export USE_CCACHE=1
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER="Kiran.Anto"
export KBUILD_BUILD_HOST="RaZor-Machine"
STRIP="$KERNEL_DIR/../../Toolchains/arm-eabi-5.2/bin/arm-eabi-strip"

compile_kernel ()
{
rm $MODULES_DIR/../RedmiOutput/anykernel/zImage
rm $MODULES_DIR/../RedmiOutput/anykernel/modules/*
rm $KERNEL_DIR/arch/arm/boot/zImage
echo -e "****************************************************"
echo -e "****************************************************"
echo -e "         _____   _____  _______ _____  _____   "
echo -e "        |  _  \ |  _  ||___   /|  _  ||  _  \  "
echo -e "        | |_|  || /_\ |    / / | | | || |_|  | "
echo -e "        |    _/ |  _  |   / /  | | | ||    _/  "
echo -e "        | |\ \  | / \ |  / /   | | | || |\ \   "
echo -e "        | | \ \ | | | | / /__  | |_| || | \ \  "
echo -e "        |_|  \_\|_| |_|/_____| |_____||_|  \_\ "
echo -e "  _____   _____  ____   _____  _____   ___      _ "
echo -e " |  _  \ | ____||  _ \ |  _  ||  _  \ |   \    | |"
echo -e " | |_|  || |    | |_| \| | | || |_|  || |\ \   | |"
echo -e " |    _/ | |___ |     || | | ||    _/ | | \ \  | |"
echo -e " | |\ \  |  ___||  _  || | | || |\ \  | |  \ \ | |"
echo -e " | | \ \ | |___ | |_| /| |_| || | \ \ | |   \ \| |"
echo -e " |_|  \_\|_____||____/ |_____||_|  \_\|_|    \___|"
echo -e "****************************************************"
echo -e "****************************************************"
make cyanogenmod_wt88047_defconfig
make -j12
if ! [ -a $KERN_IMG ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
strip_modules
}


strip_modules ()
{
echo "Copying modules"
rm $MODULES_DIR/*
find . -name '*.ko' -exec cp {} $MODULES_DIR/ \;
cd $MODULES_DIR
echo "Stripping modules for size"
$STRIP --strip-unneeded *.ko
cd $KERNEL_DIR
}

case $1 in
clean)
make ARCH=arm -j8 clean mrproper
;;
*)
compile_kernel
;;
esac
cp $KERNEL_DIR/arch/arm/boot/zImage  $MODULES_DIR/../RedmiOutput/anykernel/zImage
cp $MODULES_DIR/* $MODULES_DIR/../RedmiOutput/anykernel/modules/
cd $MODULES_DIR/../RedmiOutput/anykernel/
zipfile="RR1.0-REDMI-ALPHA-0.9-$(date +"%Y-%m-%d(%I.%M%p)").zip"
zip -r ../$zipfile ramdisk anykernel.sh dtb modules zImage patch tools META-INF -x *kernel/.gitignore*
dropbox_uploader -p upload $MODULES_DIR/../RedmiOutput/$zipfile /test/
dropbox_uploader share /test/$zipfile
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
echo "Enjoy RazorKernel"
