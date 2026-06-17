if contains_package "/debootstrap/desktop/15-packages-custom.txt" "discord"; then
	log "I KNOW ONLY SOMETIMES WORKING, because of CERT ERR!"
	log "Installing Discord..."
	wget --no-check-certificate -O "/tmp/discord.deb" "https://discordapp.com/api/download?platform=linux&format=deb"
	apt install /tmp/discord.deb -y
	rm /tmp/discord.deb
fi
