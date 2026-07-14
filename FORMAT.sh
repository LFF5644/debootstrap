#!/bin/bash
# ---- VARS ----
DEVICE=/dev/sdf
FILESYSTEM_SIZE=10G     # END-Position der FS-Partition (parted-Syntax)
FILESYSTEM_TYPE=btrfs
PARTITION_TABLE=gpt
SUBVOLUME=linux         # nur bei btrfs
SWAP_SIZE=10G           # 0 = kein Swap
TEMP_MOUNT=/mnt/clean_device
# --------------

echo "Run this as root. Requires: parted, util-linux (wipefs), btrfs-progs."

# root check
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"; exit 100
fi

# device check
if [ ! -b "$DEVICE" ]; then
	echo "Device $DEVICE does not exist."; exit 1
fi

# NVMe -> nvme0n1p1, sonst sdX1
if [[ "$DEVICE" =~ [0-9]$ ]]; then
	PART_PREFIX="${DEVICE}p"
else
	PART_PREFIX="${DEVICE}"
fi

wipefs -a "$DEVICE" || { echo "wipefs failed."; exit 1; }

filesystem_part=
swap_part=

if [ "$PARTITION_TABLE" = "gpt" ]; then
	echo "Creating GPT partition table on $DEVICE..."
	parted -s "$DEVICE" mklabel gpt

	echo "Creating BIOS-Boot-Partition... (1 MiB)"
	parted -s "$DEVICE" mkpart primary 1MiB 2MiB
	parted -s "$DEVICE" set 1 bios_grub on

	echo "Creating $FILESYSTEM_TYPE partition (end: $FILESYSTEM_SIZE)"
	parted -s "$DEVICE" mkpart primary "$FILESYSTEM_TYPE" 2MiB "$FILESYSTEM_SIZE"
	filesystem_part="${PART_PREFIX}2"

	if [ "$SWAP_SIZE" != "0" ]; then
		echo "Creating Swap partition ($SWAP_SIZE)"
		# '--' verhindert, dass parted -10G als Option interpretiert
		parted -s "$DEVICE" -- mkpart primary linux-swap "-$SWAP_SIZE" 100%
		swap_part="${PART_PREFIX}3"
	fi
else
	echo "Partition table '$PARTITION_TABLE' not supported. Use 'gpt'."
	exit 1
fi

partprobe "$DEVICE" || { echo "partprobe failed."; exit 1; }
udevadm settle

if [ "$FILESYSTEM_TYPE" = "btrfs" ]; then
	echo "Creating BTRFS on $filesystem_part"
	mkfs.btrfs -f -L LINUX "$filesystem_part" || { echo "mkfs.btrfs failed."; exit 1; }

	echo "Creating subvolume '$SUBVOLUME'"
	mkdir -p "$TEMP_MOUNT"
	mount "$filesystem_part" "$TEMP_MOUNT" || { echo "mount failed."; exit 1; }
	btrfs subvolume create "$TEMP_MOUNT/$SUBVOLUME" || { echo "subvolume create failed."; umount "$TEMP_MOUNT"; exit 1; }
	umount "$TEMP_MOUNT" || { echo "umount failed."; exit 1; }
else
	echo "Creating $FILESYSTEM_TYPE on $filesystem_part"
	mkfs."$FILESYSTEM_TYPE" -L LINUX "$filesystem_part" || { echo "mkfs.$FILESYSTEM_TYPE failed."; exit 1; }
fi

if [ "$SWAP_SIZE" != "0" ]; then
	echo "Creating SWAP (LABEL 'SWAP')"
	mkswap -L SWAP "$swap_part" || { echo "mkswap failed."; exit 1; }
fi

UUID_FILESYSTEM=$(blkid -s UUID -o value /dev/disk/by-label/LINUX)
UUID_SWAP=$(blkid -s UUID -o value /dev/disk/by-label/SWAP)
echo "UUID_FILESYSTEM:	$UUID_FILESYSTEM"
echo "UUID_SWAP:		$UUID_SWAP"
echo finished!
ls --color=auto -lah ${DEVICE}*