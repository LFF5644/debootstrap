if [ "$INSTALL_BOOTLOADER" = "grub-pc" ] && [ "$INSTALL_CHROOT_ONLY" = "false" ]; then
	log "Installing Bootloader (BIOS/i386-pc)..."
	apt_install "/debootstrap/bootloader/05-packages-grub-bios.txt"
	mkdir -p /boot/grub
	# Nur mounten, wenn separate /boot-Partition vorhanden ist
	if [ -n "$INSTALL_BOOTLOADER_DEVICE" ] && [ "$INSTALL_BOOTLOADER_DEVICE" != "NONE" ]; then
		log "Mounting /boot from $INSTALL_BOOTLOADER_DEVICE..."
		mount "$INSTALL_BOOTLOADER_DEVICE" /boot -t auto
	fi
	time update-initramfs -u
	grub-install --target=i386-pc --boot-directory=/boot "$INSTALL_BOOTLOADER_DEVICE_INSTALL"

elif [ "$INSTALL_BOOTLOADER" = "grub-efi" ]; then
	log "Installing Bootloader (EFI/x86_64-efi)..."

	log "Mounting efivars to /sys/firmware/efi/efivars..."
	mkdir -p /boot/efi /sys/firmware/efi/efivars
	mount -t efivarfs efivarfs /sys/firmware/efi/efivars
	if $? -ne 0; then log "Failed to mount efivars to /sys/firmware/efi/efivars. EFI bootloader installation may fail."; sleep 60; exit 1; fi

	if [ "$FORMART_EFI_PARTITION" = "true" ]; then
		log "Formatting EFI partition $BOOTLOADER_EFI_PARTITION as FAT32..."
		echo 'type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B' | sfdisk $BOOTLOADER_EFI_PARTITION --part-label N "EFI System Partition"
		mkfs.vfat -F 32 -n EFI $BOOTLOADER_EFI_PARTITION
	fi

	if [ "$MOUNT_REAL_ROOT" = "true" ]; then
		log "Mounting real ROOT partition $FSTAB_ROOT_DEVICE to /mnt..."
		mkdir -p /mnt
		mount "$FSTAB_ROOT_DEVICE" /mnt -t $FSTAB_ROOT_TYPE -o "$FSTAB_ROOT_OPTIONS"
		if $? -ne 0; then log "Failed to mount real root partition $FSTAB_ROOT_DEVICE to /mnt. EFI bootloader installation may fail."; sleep 60; exit 1; fi
	fi

	if [ "$MOUNT_REAL_BOOT" = "true" ]; then
		log "Mounting real BOOT partition $FSTAB_BOOT_DEVICE to /boot..."
		mkdir -p /boot/efi
		mount "$FSTAB_BOOT_DEVICE" /boot/efi -t vfat
		if $? -ne 0; then log "Failed to mount real boot partition $FSTAB_BOOT_DEVICE to /boot/efi. EFI bootloader installation may fail."; sleep 60; exit 1; fi
	fi

	#testing partition mounts
	echo "mounted partitions:"
	ls -l /mnt /boot /boot/efi /sys/firmware/efi/efivars

	apt_install "/debootstrap/bootloader/05-packages-grub-efi.txt"

	mkdir -p /boot/grub
	time update-initramfs -u
	grub-install --target=x86_64-efi --efi-directory=/boot/efi --boot-directory=/boot --bootloader-id=LFF-Linux --removable
fi
