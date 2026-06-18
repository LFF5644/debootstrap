if contains_package "/debootstrap/desktop/15-packages-custom.txt" "discord"; then
	log "Installing Discord..."
	download "https://discordapp.com/api/download?platform=linux&format=deb" /tmp/discord.deb
	apt install /tmp/discord.deb -y
	rm /tmp/discord.deb
fi
