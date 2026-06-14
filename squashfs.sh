export target_root=/tmp/debootstrap
export target_boot=/media/lff/BOOT
export target_device="/dev/sdf"

mkdir -p $target_root/debootstrap $target_boot
sudo cp -rvT template/debootstrap/squashfs.sh $target_root/debootstrap/squashfs.sh

echo mounting / binding to chroot...
sudo mount --bind /dev $target_root/dev
sudo mount --bind /proc $target_root/proc
sudo mount --bind /sys $target_root/sys
sudo mount --bind $target_boot $target_root/boot

echo now ruinning in shroot...
time sudo chroot $target_root bash /debootstrap/squashfs.sh $target_device

echo finishing! now u cat use the terminal.
sudo chroot $target_root bash

echo unmounting / unbinding ...
sudo umount $target_root/dev
sudo umount $target_root/proc
sudo umount $target_root/sys
sudo umount $target_root/boot

time sudo mksquashfs $target_root filesystem.squashfs -e boot -comp zstd -Xcompression-level 19 -mem-percent 50 -info -progress

# sudo mksquashfs / /mnt/filesystem-current.squashfs -e boot proc sys dev run tmp mnt media lost+found -comp zstd -Xcompression-level 19 -mem-percent 50 -info -progress