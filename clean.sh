KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/arch/arm64/boot/Image
DTBTOOL=$KERNEL_DIR/tools/dtbToolCM
MODULES_DIR=$KERNEL_DIR/../RaZORBUILDOUTPUT/Common
export CROSS_COMPILE="$MODULES_DIR/../../../Toolchains/aarch64-linux-android-5.2-kernel/bin/aarch64-linux-android-"
export LD_LIBRARY_PATH="$MODULES_DIR/../../../Toolchains/sabermod-prebuilts/usr/lib/"
export USE_CCACHE=1
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Kiran.Anto"
export KBUILD_BUILD_HOST="RaZor-Machine"
STRIP="$MODULES_DIR/../../../Toolchains/aarch64-linux-android-5.2-kernel/bin/aarch64-linux-android-strip"
make clean
make mrproper

