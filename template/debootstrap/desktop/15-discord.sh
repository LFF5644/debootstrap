if contains_package "/debootstrap/desktop/15-packages-custom.txt" "discord"; then
	log "Installing Discord..."
	wget -O "/tmp/discord.deb" "https://discordapp.com/api/download?platform=linux&format=deb"
	apt install /tmp/discord.deb -y
	rm /tmp/discord.deb
fi
