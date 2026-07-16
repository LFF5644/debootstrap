boot_directory=none

update_grub(){
	log "hacking grub-probe ..."
	mv /sbin/grub-probe /debootstrap/backup/
	echo -e "#!/bin/bash\n echo '$FSTAB_ROOT_DEVICE_TYPE';exit 0" > /sbin/grub-probe
	chmod +x /sbin/grub-probe
	log "hacked! update-grub ..."
	update-grub
	a=1
	if [ $a = 1 ]; then # [ $? -ne 0 ] && [ ! -f "$boot_directory/grub/grub.cfg" ] && [ ! -f "/boot/grub/grub.cfg" ] # disabled, because grub-update can fail but still create a working grub.cfg
		# NOTE: /boot (tmpfs), $boot_directory (real device); later tmpfs will be copied to real device and overwrite everything existing.
		log "Error with grub-update! using hack xD";
		log "Creating vmlinuz & initrd.img symbolic links in /boot..."
		cd /boot;
		ln -sf $(ls vmlinuz-* | sort -V | tail -n 1) vmlinuz # Erstellt den Link für den Kernel
		ln -sf $(ls initrd.img-* initramfs-* 2>/dev/null | sort -V | tail -n 1) initrd.img # Erstellt den Link für die Initrd / Initramfs
		cd "-"; ls -lah /boot;
		log "links created. building hacky grub.cfg...";
		[ -f "$boot_directory/grub/grub.cfg" ] && { log "moving existing config away... '$boot_directory/grub/grub.cfg' (device) --> 'grub.unknown.cfg'"; mv "$boot_directory/grub/grub.cfg" "$boot_directory/grub/grub.unknown.cfg"; }
		[ -f "/boot/grub/grub.cfg" ] && { log "moving existing config away... '/boot/grub/grub.cfg' (tmpfs) --> 'grub.auto.cfg'"; mv "/boot/grub/grub.cfg" "/boot/grub/grub.auto.cfg"; }
		SUBVOLUME=$(echo ",$FSTAB_ROOT_MOUNT_OPTIONS," | sed -n 's/.*,subvol=\([^,]*\),.*/\/\1/p')
		cat << EOF > "$boot_directory/grub/grub.cfg"
# Funny Note: Hey ähm wenn du das siehst hast du mich ganz schön beim basteln erwischt, mist! Führe 'sudo update-grub' aus ums zu 'heilen' xD
# Technical Note: Yeah that was my try to make an minimal booting grub.cfg, hope it worked; that is just for once use update-grub to create original one ;-)
# Note: This File was Created by https://github.com/LFF5644/debootstrap/ at $(date).
echo "welcome into grub, if u see that text longer then 10s something went wrong :-("
echo "if that will happen just google or ask any ai 'grub boot not working, shell manuell boot.' that should help you. :)"
echo "in any case: after this BOOTs up run $ sudo update-grub if /boot/grub/grub.cfg is not changed."
echo ""
echo "loading modules into bootloader..."
insmod play
insmod part_gpt
insmod part_msdos
insmod $FSTAB_ROOT_DEVICE_TYPE
set timeout=0
set default=0
set btrfs_relative_path=y
echo searching and selecting kernel...
search --no-floppy --fs-uuid --set=root ${FSTAB_ROOT_DEVICE:5}
echo loading kernel ($SUBVOLUME/vmlinuz) into memory...
linux $SUBVOLUME/boot/vmlinuz root=$FSTAB_ROOT_DEVICE rootflags=$FSTAB_ROOT_MOUNT_OPTIONS $KERNEL_CMDLINE
echo loading initramfs ($SUBVOLUME/initrd.img) into memory...
initrd $SUBVOLUME/boot/initrd.img
echo OK.
echo playing sound...
play 480 440 4 440 4 440 4 349 3 523 1 440 4 349 3 523 1 440 8 659 4 659 4 659 4 698 3 523 1 415 4 349 3 523 1 440 8
echo booting loaded kernel...
boot
EOF
		log "hacky grub.cfg created. continue..."
		sleep 15;
	elif [ $? -ne 0 ] && [[ -f "/boot/grub/grub.cfg" || -f "$boot_directory/grub/grub.cfg" ]]; then
		log "Error with grub-update! using hack xD\nINFO: /boot/grub/grub.cfg exists, maybe u have luck and it will boot! continue ...";
		sleep 15;
	else log "internal 'if' error in script: $SCRIPT"; sleep 15; exit 1;
	fi

	log "restore not hacked grub-probe ..."
	rm /sbin/grub-probe; mv /debootstrap/backup/grub-probe /sbin/
	log "restored."
}
if [ "$INSTALL_BOOTLOADER" = "grub-pc" ] && [ "$INSTALL_CHROOT_ONLY" = "false" ]; then
	umount_bios(){
		if [ $1 -ne 0 ]; then log "Error occurred during BIOS bootloader installation. Try to Find out or Fix it in shell, load 'source /debootstrap/config.env'. after exit it will clean mount points"; bash; exit 1; fi
		log "Unmounting stuff for bios bootloader installation ..."
		umount -q -A /mnt/linux
		log "Unmounting completed."
	}
	log "Installing Bootloader (BIOS/i386-pc)..."
	apt_install "/debootstrap/bootloader/05-packages-grub-bios.txt"
	mkdir -p /boot/grub
	# Nur mounten, wenn separate /boot-Partition vorhanden ist
	if [ -n "$BOOTLOADER_BIOS_PARTITION" ] && [ "$BOOTLOADER_BIOS_PARTITION" != "none" ]; then
		log "Mounting /boot from $BOOTLOADER_BIOS_PARTITION to /mnt/boot for bootloader install..."
		mkdir -p /mnt/boot
		mount "$BOOTLOADER_BIOS_PARTITION" /mnt/boot -t auto
		if [ $? -ne 0 ]; then log "Failed to mount /boot from $BOOTLOADER_BIOS_PARTITION. BIOS bootloader installation may fail."; umount_bios 15;
		else boot_directory=/mnt/boot; fi
	elif [ "$MOUNT_REAL_ROOT" = "true" ]; then
		log "mounting real root partition $FSTAB_ROOT_DEVICE ($FSTAB_ROOT_DEVICE_TYPE) to /mnt/linux for bios bootloader installation..."
		mkdir -p /mnt/linux
		mount "$FSTAB_ROOT_DEVICE" /mnt/linux -t $FSTAB_ROOT_DEVICE_TYPE -o "$FSTAB_ROOT_MOUNT_OPTIONS"
		if [ $? -ne 0 ]; then log "Failed to mount real root partition $FSTAB_ROOT_DEVICE with -o '$FSTAB_ROOT_MOUNT_OPTIONS' to /mnt/linux. BIOS bootloader installation may fail."; umount_bios 15
		else boot_directory=/mnt/linux/boot; fi
	else
		log "Can not mount, but access to '/boot' is required!";
		umount_bios 15;
		exit 1;
	fi
	log "Install Bootloader to '$boot_directory' on device $BOOTLOADER_BIOS_DEVICE ..."
	grub-install --target=i386-pc --boot-directory=$boot_directory "$BOOTLOADER_BIOS_DEVICE"
	if [ $? -ne 0 ]; then log "grub-install failed. BIOS bootloader installation may have failed on '$BOOTLOADER_BIOS_DEVICE'. Please fix the issue manually."; umount_bios 15; exit 1; fi
	log "Update grub config ..."
	update_grub
	if [ $? -ne 0 ]; then log "update-grub failed."; umount_bios 15; exit 1; fi
	umount_bios 0

elif [ "$INSTALL_BOOTLOADER" = "grub-efi" ]; then
	#boot_directory=/mnt/boot/efi # TODO
	log efi boot?? IHHH was das den! baue ich später ein sry xxD
	exit 1;

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
