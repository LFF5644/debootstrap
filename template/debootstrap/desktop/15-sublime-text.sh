if contains_package "/debootstrap/desktop/15-packages-custom.txt" "sublime-text"; then
	channel="stable"
	log "Installing Sublime Text..."
	download "http://download.sublimetext.com/sublimehq-pub.gpg" /etc/apt/keyrings/sublimehq-pub.asc
	echo -e "Types: deb\nURIs: http://download.sublimetext.com/\nSuites: apt/$channel/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc" > /etc/apt/sources.list.d/sublime-text.sources
	log "Updating package lists... Install Sublime Text..."
	apt update; apt install sublime-text -y
fi
