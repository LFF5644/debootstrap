#!/bin/bash
# Please Change the VARS
DEVICE=/dev/sdf
FILESYSTEM_SIZE=10G
FILESYSTEM_TYPE=btrfs
PARTITION_TABLE=gpt
SUBVOLUME=linux # only for btrfs
SWAP_SIZE=10G # 0 if u not want a swap
TEMP_MOUNT=/mnt/clean_device

echo "be sure that u running this as root and have the packages wipefs and parted installed."
echo "$ sudo apt install wipefs parted -y"

# check if device exists
if [ ! -b "$DEVICE" ]; then
	echo "Device $DEVICE does not exist. Please check the device path."
	exit 1
fi

# check if user is root
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit 100
fi

wipefs -a "$DEVICE"

filesystem_part=
swap_part=
if [ "$PARTITION_TABLE" = "gpt" ]; then
	echo "Creating GPT partition table on $DEVICE..."
	parted -s "$DEVICE" mklabel gpt
	
	# 1 MiB BIOS-Boot-Partition
	echo "Creating BIOS-Boot-Partition... (1 MiB)"
	parted -s "$DEVICE" mkpart primary 1MiB 2MiB
	parted -s "$DEVICE" set 1 bios_grub on

	# BTRFS-Partition (danach)
	echo "Creating $FILESYSTEM_TYPE-Partition... ($FILESYSTEM_SIZE)"
	parted -s "$DEVICE" mkpart primary $FILESYSTEM_TYPE 2MiB $FILESYSTEM_SIZE
	filesystem_part=${DISK}2

	if [ "$SWAP_SIZE" != "0" ]; then
		# Swap-Partition (am Ende)
		echo "Creating Swap-Partition... ($SWAP_SIZE)"
		parted -s "$DEVICE" mkpart primary linux-swap -$SWAP_SIZE 100%
		swap_part=${DISK}3
	fi

fi
else
	echo "filesystem type $PARTITION_TABLE not supported. Please use 'gpt'."
	exit 1
fi

partprobe "$DISK"
if [ $? -ne 0 ]; then echo "partprobe failed. Please check the device and try again."; exit 1; fi
udevadm settle

if [ "$FILESYSTEM_TYPE" == "btrfs"]; then
	echo "Creating BTRFS-FILESYSTEM on $filesystem_part"
	mkfs.btrfs -f -L LINUX "$filesystem_part"
	if [ $? -ne 0 ]; then echo "mkfs.btrfs failed. Please check the device and try again."; exit 1; fi
	
	echo "Creating BTRFS subvolume '$SUBVOLUME' on $filesystem_part"
	mkdir -p "$TEMP_MOUNT"
	mount "$filesystem_part" "$TEMP_MOUNT"
	if [ $? -ne 0 ]; then echo "mount failed. Please check the device and try again."; exit 1; fi
	btrfs subvolume create "$TEMP_MOUNT/$SUBVOLUME"
	if [ $? -ne 0 ]; then echo "btrfs subvolume create failed. Please check the device and try again."; exit 1; fi
	umount "$TEMP_MOUNT"
	if [ $? -ne 0 ]; then echo "umount failed. Please check the device and try again."; exit 1; fi
fi
else
	echo "Creating $FILESYSTEM_TYPE-FILESYSTEM on $filesystem_part"
	mkfs.$FILESYSTEM_TYPE -f -L LINUX "$filesystem_part"
	if [ $? -ne 0 ]; then echo "mkfs.$FILESYSTEM_TYPE failed. Please check the device and try again."; exit 1; fi
fi

if [ "$SWAP_SIZE" != "0" ]; then
	echo "Creating SWAP partition with LABEL 'SWAP'."
	mkswap -L SWAP "$swap_part"
fi

UUID_FILESYSTEM=$(blkid -s UUID -o value /dev/disk/by-label/LINUX)
UUID_SWAP=$(blkid -s UUID -o value /dev/disk/by-label/SWAP)
echo "UUID_FILESYSTEM: $UUID_FILESYSTEM"
echo "UUID_SWAP: $UUID_SWAP"
