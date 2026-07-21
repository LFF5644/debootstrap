#!/bin/bash
echo loading config...
source config.env
echo "mounting real root partition $FSTAB_ROOT_DEVICE ($FSTAB_ROOT_DEVICE_TYPE) to $ROOT_TARGET for copy..."
mkdir -p "$ROOT_TARGET"
mount "$FSTAB_ROOT_DEVICE" "$ROOT_TARGET" -t $FSTAB_ROOT_DEVICE_TYPE -o "$FSTAB_ROOT_MOUNT_OPTIONS"
echo "Starting copy to real device... $ROOT_INSTALL --> $ROOT_TARGET"
time sudo cp -a "$ROOT_INSTALL/." "$ROOT_TARGET"; time sync
echo "copy to real device completed."
umount "$ROOT_TARGET"
