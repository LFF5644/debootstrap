#!/bin/bash
export INSTALL_DEVICE=NONE # ONLY REQUIRED FOR BIOS BOOT (GRUB i386)
export BOOT_PARTITION=/dev/sda1

mkdir -p /boot/efi
mount $BOOT_PARTITION /boot -t auto

# Installing Bootloader GRUB
apt install --no-install-recommends -y grub-efi linux-image-amd64 initramfs-tools xz-utils

update-initramfs -u
grub-install --target=x86_64-efi --compress=xz -v --core-compress=xz --efi-directory=/boot --boot-directory=/boot --bootloader-id=LFF-Linux
# need "Installation finished. No error reported." :P

#grub-install --target=i386-pc --boot-directory=/boot $INSTALL_DEVICE

umount /boot
