#!/system/bin/sh

PATH=/sbin:/system/sbin:/system/bin:/system/xbin
export PATH

BBX=/system/xbin/busybox

# Inicio
mount -o remount,rw -t auto /
mount -o remount,rw -t auto /system
mount -t rootfs -o remount,rw rootfs

if [ -f $BBX ]; then
	chown 0:2000 $BBX
	chmod 0755 $BBX
	$BBX --install -s /system/xbin
	ln -s $BBX /sbin/busybox
	ln -s $BBX /system/bin/busybox
	sync
fi

# Set environment and create symlinks: /bin, /etc, /lib, and /etc/mtab
set_environment ()
{
	# create /bin symlinks
	if [ ! -e /bin ]; then
		$BBX ln -s /system/bin /bin
	fi

	# create /etc symlinks
	if [ ! -e /etc ]; then
		$BBX ln -s /system/etc /etc
	fi

	# create /lib symlinks
	if [ ! -e /lib ]; then
		$BBX ln -s /system/lib /lib
	fi

	# symlink /etc/mtab to /proc/self/mounts
	if [ ! -e /system/etc/mtab ]; then
		$BBX ln -s /proc/self/mounts /system/etc/mtab
	fi
}

if [ -x $BBX ]; then
	set_environment
fi

########################################################
#Supersu
#
/system/xbin/daemonsu --auto-daemon &

########################################################
# kernel custom test
#

if [ -e /data/carbontest.log ]; then
	rm /data/carbontest.log
fi

echo  Kernel script is working !!! >> /data/carbontest.log
echo "excecuted on $(date +"%d-%m-%Y %r" )" >> /data/carbontest.log
echo  Done ! >> /data/carbontest.log

########################################################
#FSTRIM
#
$BBX fstrim -v /system >> /data/carbontest.log
$BBX fstrim -v /cache >> /data/carbontest.log
$BBX fstrim -v /data >> /data/carbontest.log

########################################################
# LMK Tweaks
#
echo "2560,4096,8192,16384,24576,32768" > /sys/module/lowmemorykiller/parameters/minfree
echo "32" > /sys/module/lowmemorykiller/parameters/cost

########################################################
# initialize init.d
#
if [ -d /system/etc/init.d ]; then
	/sbin/busybox run-parts /system/etc/init.d
fi;

########################################################
# Allow untrusted apps to read from debugfs
#
if [ -e /system/lib/libsupol.so ]; then
/system/xbin/supolicy --live \
	"allow untrusted_app debugfs file { open read getattr }" \
	"allow untrusted_app sysfs_lowmemorykiller file { open read getattr }" \
	"allow untrusted_app sysfs_devices_system_iosched file { open read getattr }" \	
	"allow untrusted_app persist_file dir { open read getattr }" \
	"allow debuggerd gpu_device chr_file { open read getattr }" \
	"allow netd netd capability fsetid" \
	"allow netd { hostapd dnsmasq } process fork" \
	"allow { system_app shell } dalvikcache_data_file file write" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file dir { search r_file_perms r_dir_perms }" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file file { r_file_perms r_dir_perms }" \
	"allow system_server { rootfs resourcecache_data_file } dir { open read write getattr add_name setattr create remove_name rmdir unlink link }" \
	"allow system_server resourcecache_data_file file { open read write getattr add_name setattr create remove_name unlink link }" \
	"allow system_server dex2oat_exec file rx_file_perms" \
	"allow mediaserver mediaserver_tmpfs file execute" \
	"allow drmserver theme_data_file file r_file_perms" \
	"allow zygote system_file file write" \
	"allow atfwd property_socket sock_file write" \
	"allow untrusted_app sysfs_display file { open read write getattr add_name setattr remove_name }" \	
	"allow debuggerd app_data_file dir search" \
	"allow sensors diag_device chr_file { read write open ioctl }" \
	"allow sensors sensors capability net_raw" \
	"allow init kernel security setenforce" \
	"allow netmgrd netmgrd netlink_xfrm_socket nlmsg_write" \
	"allow netmgrd netmgrd socket { read write open ioctl }"
fi;

########################################################
# Google Services battery drain fixer
#

# stop google service and restart it on boot. this remove high cpu load and ram leak!
	if [ "$($BBX pidof com.google.android.gms | wc -l)" -eq "1" ]; then
		$BBX kill "$($BBX pidof com.google.android.gms)";
	fi;
	if [ "$($BBX pidof com.google.android.gms.unstable | wc -l)" -eq "1" ]; then
		$BBX kill "$($BBX pidof com.google.android.gms.unstable)";
	fi;
	if [ "$($BBX pidof com.google.android.gms.persistent | wc -l)" -eq "1" ]; then
		$BBX kill "$($BBX pidof com.google.android.gms.persistent)";
	fi;
	if [ "$($BBX pidof com.google.android.gms.wearable | wc -l)" -eq "1" ]; then
		$BBX kill "$($BBX pidof com.google.android.gms.wearable)";
	fi;

# Google Services battery drain fixer by Alcolawl@xda
# http://forum.xda-developers.com/google-nexus-5/general/script-google-play-services-battery-t3059585/post59563859
pm enable com.google.android.gms/.update.SystemUpdateActivity
pm enable com.google.android.gms/.update.SystemUpdateService
pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver
pm enable com.google.android.gms/.update.SystemUpdateService$Receiver
pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver
pm enable com.google.android.gsf/.update.SystemUpdateActivity
pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity
pm enable com.google.android.gsf/.update.SystemUpdateService
pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver
pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver

########################################################
# Power Effecient Workqueues (Enable for battery)
#
echo "1" > /sys/module/workqueue/parameters/power_efficient
echo "0" > /sys/module/subsystem_restart/parameters/enable_ramdumps
