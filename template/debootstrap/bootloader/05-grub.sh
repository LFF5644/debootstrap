update_grub(){
	log "hacking grub-probe ..."
	mv /sbin/grub-probe /debootstrap/backup/
	echo -e "#!/bin/bash\n echo '$(/debootstrap/backup/grub-probe /boot)';exit 0" > /sbin/grub-probe
	chmod +x /sbin/grub-probe
	log "hacked! update-grub ..."
	update-grub
	if [ $? -ne 0 ]; then log "Error with grub-update! fix it! continue ..."; sleep 15; fi
	log "restore not hacked grub-probe ..."
	rm /sbin/grub-probe; mv /debootstrap/backup/grub-probe /sbin/
	log "restored."
}
if [ "$INSTALL_BOOTLOADER" = "grub-pc" ] && [ "$INSTALL_CHROOT_ONLY" = "false" ]; then
	umount_bios(){
		if [ $1 -ne 0 ]; then log "Error occurred during BIOS bootloader installation. Try to Find out or Fix it in shell, load 'source /debootstrap/config.env'. after exit it will clean mount points"; bash; exit 1; fi
		log "Unmounting stuff for bios bootloader installation ..."
		umount /boot
		umount /mnt
		log "Unmounting completed."
	}
	log "Installing Bootloader (BIOS/i386-pc)..."
	apt_install "/debootstrap/bootloader/05-packages-grub-bios.txt"
	mkdir -p /boot/grub
	# Nur mounten, wenn separate /boot-Partition vorhanden ist
	if [ -n "$BOOTLOADER_BIOS_PARTITION" ] && [ "$BOOTLOADER_BIOS_PARTITION" != "none" ]; then
		log "Mounting /boot from $BOOTLOADER_BIOS_PARTITION..."
		mount "$BOOTLOADER_BIOS_PARTITION" /boot -t auto
		if [ $? -ne 0 ]; then log "Failed to mount /boot from $BOOTLOADER_BIOS_PARTITION. BIOS bootloader installation may fail."; umount_bios 15; fi
	elif [ "$MOUNT_REAL_ROOT" = "true" ]; then
		log "mounting real root partition $FSTAB_ROOT_DEVICE ($FSTAB_ROOT_DEVICE_TYPE) to /mnt for bios bootloader installation..."
		mkdir -p /mnt
		mount "$FSTAB_ROOT_DEVICE" /mnt -t $FSTAB_ROOT_DEVICE_TYPE -o "$FSTAB_ROOT_MOUNT_OPTIONS"
		if [ $? -ne 0 ]; then log "Failed to mount real root partition $FSTAB_ROOT_DEVICE with -o '$FSTAB_ROOT_MOUNT_OPTIONS' to /mnt. BIOS bootloader installation may fail."; umount_bios 15; fi
		mkdir -p /mnt/boot
		mount --bind /mnt/boot /boot
		if [ $? -ne 0 ]; then log "Failed to bind mount /mnt/boot to /boot. BIOS bootloader installation may fail."; umount_bios 15; fi
	fi
	log "Install Bootloader to $BOOTLOADER_BIOS_DEVICE ..."
	grub-install --target=i386-pc --boot-directory=/boot "$BOOTLOADER_BIOS_DEVICE"
	if [ $? -ne 0 ]; then log "grub-install failed. BIOS bootloader installation may have failed. Please fix the issue manually."; umount_bios 15; exit 1; fi
	log "Update grub config ..."
	update_grub
	if [ $? -ne 0 ]; then log "update-grub failed."; umount_bios 15; exit 1; fi
	umount_bios 0

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
		
		UUID=$(blkid -s UUID -o value "$BOOTLOADER_EFI_PARTITION")
		FSTAB_BOOT_EFI_DEVICE="UUID=${UUID}"
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
		log "Mounting real BOOT partition $FSTAB_BOOT_EFI_DEVICE to /boot/efi..."
		mkdir -p /boot/efi
		mount "$FSTAB_BOOT_EFI_DEVICE" /boot/efi -t vfat
		if [ $? -ne 0 ]; then log "Failed to mount real boot partition $FSTAB_BOOT_EFI_DEVICE to /boot/efi. EFI bootloader installation may fail."; umount_efi 15; fi
	fi

	#testing partition mounts
	echo "mounted partitions:"
	ls -l /mnt /boot /boot/efi /sys/firmware/efi/efivars

	apt_install "/debootstrap/bootloader/05-packages-grub-efi.txt"

	mkdir -p /boot/grub
	#time update-initramfs -u
	log "Installing GRUB EFI bootloader to $BOOTLOADER_EFI_PARTITION..."
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
	update_grub
	umount_efi 0
fi
