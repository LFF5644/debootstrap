if [ "$INSTALL_DESKTOP_PACKAGES" = "true" ] && contains_package "/debootstrap/desktop/15-packages-custom.txt" "discord"; then
	log "Installing Discord..."
	download "https://discordapp.com/api/download?platform=linux&format=deb" /tmp/discord.deb
	apt_install_package /tmp/discord.deb
	rm /tmp/discord.deb
fi
