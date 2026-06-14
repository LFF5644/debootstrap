if [ "$FSTAB_BUILD" = "true" ]; then
	log "Building fstab with the following settings:"
	log "ROOT_DEVICE: $FSTAB_ROOT_DEVICE"
	log "ROOT_TYPE: $FSTAB_ROOT_TYPE"
	log "ROOT_OPTIONS: $FSTAB_ROOT_OPTIONS"
	log "SWAP_DEVICE: $FSTAB_SWAP_DEVICE"
	log "BOOT_DEVICE: $FSTAB_BOOT_DEVICE"
	
	cat /etc/fstab > /etc/fstab.bak
	echo -e "\n\n#### Generated fstab by 01-build-fstab.sh ####\n# Linux-Root" > /etc/fstab
	echo "$FSTAB_ROOT_DEVICE / $FSTAB_ROOT_TYPE $FSTAB_ROOT_OPTIONS 0 0" >> /etc/fstab

	if [ "$FSTAB_BOOT_DEVICE" != "none" ]; then
		echo -e "\n# Boot Partition (BIOS/UEFI)" >> /etc/fstab
		echo "$FSTAB_BOOT_DEVICE $FSTAB_BOOT_DEVICE_MOUNTPOINT vfat umask=0077 0 1" >> /etc/fstab
	fi

	if [ "$FSTAB_SWAP_DEVICE" != "none" ]; then
		echo -e "\n# Swap" >> /etc/fstab
		echo "$FSTAB_SWAP_DEVICE none swap sw 0 0" >> /etc/fstab
	fi
	echo -e "\n#### End of generated fstab ####\n" >> /etc/fstab
	cat /etc/fstab.bak >> /etc/fstab
	# rm /etc/fstab.bak # TODO xD
else
	log "Skipping fstab build, using custom fstab from /debootstrap/bootloader/fstab"
fi