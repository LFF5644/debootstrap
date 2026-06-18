if contains_package "/debootstrap/desktop/15-packages-custom.txt" "spotify-client"; then
	log "Installing Spotify client..."
	channel="stable"
	download "http://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc" "-" | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
	echo "deb http://repository.spotify.com $channel non-free" > /etc/apt/sources.list.d/spotify.list
	apt update; apt install spotify-client -y
fi
