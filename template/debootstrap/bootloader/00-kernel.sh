if [ "$INSTALL_KERNEL" = "true" ]; then
	log "Installing Kernel & Initramfs..."
	apt_install "/debootstrap/bootloader/00-packages-kernel.txt"
fi
