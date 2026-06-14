if [ "$INSTALL_BOOTLOADER" = "grub-pc" ] && [ "$INSTALL_CHROOT_ONLY" = "false" ]; then
	log "Installing Bootloader..."
	apt_install "/debootstrap/bootloader/05-packages-grub-bios.txt"
	mount $INSTALL_BOOTLOADER_DEVICE /boot -t auto
	time update-initramfs -u
	grub-install --target=i386-pc --boot-directory=/boot $INSTALL_BOOTLOADER_DEVICE_INSTALL
fi
