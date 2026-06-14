apt_install "/debootstrap/base/03-packages-base.txt"

# install CLI tools if needed
if [ "$INSTALL_CLI_TOOLS" = "true" ]; then
	apt_install "/debootstrap/base/03-packages-cli-tools.txt"
fi

# install network tools if needed
if [ "$INSTALL_NETWORK_TOOLS" = "true" ]; then
	apt_install "/debootstrap/base/03-packages-network-tools.txt"
	if [ "$INSTALL_CHROOT_ONLY" = "false" ]; then
		apt_install "/debootstrap/base/03-packages-network-kernel.txt"
	fi
fi
