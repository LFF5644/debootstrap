if [ "$INSTALL_BOOTLOADER" = "grub-pc" ] && [ "$INSTALL_CHROOT_ONLY" = "false" ]; then
	log "Installing Bootloader (BIOS/i386-pc)... NOT IMPLEMENTED YET!"
	sleep 15
	exit 1

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
	umount_efi(){
		if [ $1 -ne 0 ]; then log "Error occurred during EFI bootloader installation. Try to Find out or Fix it in shell, load 'source /debootstrap/config.env'. after exit it will clean mount points"; bash; sleep $1; exit 1; fi
		log "Unmounting stuff for efi bootloader installation ..."
		umount /sys/firmware/efi/efivars
		umount /boot/efi
		umount /boot
		umount /mnt
		log "Unmounting completed."
	}
	log "Installing Bootloader (EFI/x86_64-efi)..."

	log "Mounting efivars to /sys/firmware/efi/efivars..."
	mkdir -p /boot/efi /sys/firmware/efi/efivars
	mount -t efivarfs efivarfs /sys/firmware/efi/efivars
	if $? -ne 0; then log "Failed to mount efivars to /sys/firmware/efi/efivars. EFI bootloader installation may fail."; umount_efi 15; sleep 60; exit 1; fi

	if [ "$FORMART_EFI_PARTITION" = "true" ]; then
		log "not supported rn LOL"; umount_efi 0; exit 1 # TODO xD
		log "Formatting EFI partition $BOOTLOADER_EFI_PARTITION as FAT32..."
		echo 'type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B' | sfdisk $BOOTLOADER_EFI_PARTITION --part-label N "EFI System Partition"
		mkfs.vfat -F 32 -n EFI $BOOTLOADER_EFI_PARTITION
		
		# Auslesen der UUID und in Variable speichern
		UUID=$(blkid -s UUID -o value "$BOOTLOADER_EFI_PARTITION") # wont work!!
		FSTAB_BOOT_DEVICE="UUID=${UUID}"
		log "formatted!, EFI partition UUID: $UUID"
	fi

	if [ "$MOUNT_REAL_ROOT" = "true" ]; then
		log "Mounting real ROOT partition $FSTAB_ROOT_DEVICE ($FSTAB_ROOT_DEVICE_TYPE) to /mnt..."
		mkdir -p /mnt
		mount "$FSTAB_ROOT_DEVICE" /mnt -t $FSTAB_ROOT_DEVICE_TYPE -o "$FSTAB_ROOT_MOUNT_OPTIONS"
		if [ $? -ne 0 ]; then log "Failed to mount real root partition $FSTAB_ROOT_DEVICE with -o '$FSTAB_ROOT_MOUNT_OPTIONS' to /mnt. EFI bootloader installation may fail."; umount_efi 15; fi
		mkdir -p /mnt$FSTAB_BOOT_DEVICE_MOUNTPOINT
		mount --bind /mnt/boot /boot
		if [ $? -ne 0 ]; then log "Failed to bind mount /mnt/boot to /boot. EFI bootloader installation may fail."; umount_efi 15; fi
	fi

	if [ "$MOUNT_REAL_BOOT" = "true" ]; then
		log "Mounting real BOOT partition $FSTAB_BOOT_DEVICE to /boot..."
		mkdir -p /boot/efi
		mount "$FSTAB_BOOT_DEVICE" /boot/efi -t vfat
		if [ $? -ne 0 ]; then log "Failed to mount real boot partition $FSTAB_BOOT_DEVICE to /boot/efi. EFI bootloader installation may fail."; umount_efi 15; fi
	fi

	#testing partition mounts
	echo "mounted partitions:"
	ls -l /mnt /boot /boot/efi /sys/firmware/efi/efivars

	apt_install "/debootstrap/bootloader/05-packages-grub-efi.txt"

	mkdir -p /boot/grub
	#time update-initramfs -u
	log "Installing GRUB EFI bootloader to $INSTALL_BOOTLOADER_DEVICE_INSTALL..."
	grub-install --target=x86_64-efi --efi-directory=/boot/efi --boot-directory=/boot --bootloader-id=LFF-Linux
	if [ $? -ne 0 ]; then
		log "grub-install failed. EFI bootloader installation may have failed.\nRetrying with --removable option... STRG+C to abort and fix the issue manually.";
		if [ $? -ne 0 ]; then log "User aborted EFI bootloader installation. Please fix the issue manually."; umount_efi 15; fi
		sleep 15
		log "Retrying grub-install with --removable option..."
		grub-install --target=x86_64-efi --efi-directory=/boot/efi --boot-directory=/boot --bootloader-id=LFF-Linux --removable
		if [ $? -ne 0 ]; then log "grub-install with --removable also failed. EFI bootloader installation has likely failed. Please fix the issue manually."; umount_efi 15; fi
	fi
	log "GRUB EFI bootloader installation completed with code '$?' JUU!"
	umount_efi 0
fi
