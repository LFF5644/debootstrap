export target_root=/tmp/debootstrap
export target_boot=/media/lff/BOOT
export target_device="/dev/sdf"

mkdir -p $ROOT_INSTALL/debootstrap $target_boot
sudo cp -rvT template/debootstrap/squashfs.sh $ROOT_INSTALL/debootstrap/squashfs.sh

echo mounting / binding to chroot...
sudo mount --bind /dev $ROOT_INSTALL/dev
sudo mount --bind /proc $ROOT_INSTALL/proc
sudo mount --bind /sys $ROOT_INSTALL/sys
sudo mount --bind $target_boot $ROOT_INSTALL/boot

echo now ruinning in shroot...
time sudo chroot $ROOT_INSTALL bash /debootstrap/squashfs.sh $target_device

echo finishing! now u cat use the terminal.
sudo chroot $ROOT_INSTALL bash

echo unmounting / unbinding ...
sudo umount $ROOT_INSTALL/dev
sudo umount $ROOT_INSTALL/proc
sudo umount $ROOT_INSTALL/sys
sudo umount $ROOT_INSTALL/boot

time sudo mksquashfs $ROOT_INSTALL filesystem.squashfs -e boot -comp zstd -Xcompression-level 19 -mem-percent 50 -info -progress

# sudo mksquashfs / /mnt/filesystem-current.squashfs -e boot proc sys dev run tmp mnt media lost+found -comp zstd -Xcompression-level 19 -mem-percent 50 -info -progress