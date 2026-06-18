if contains_package "/debootstrap/desktop/15-packages-custom.txt" "signal-desktop"; then
	log "Installing Signal Desktop. Downloading..."
	download "https://updates.signal.org/desktop/apt/keys.asc" "-" | gpg --dearmor --yes -o /usr/share/keyrings/signal-desktop-keyring.gpg;
	download "https://updates.signal.org/static/desktop/apt/signal-desktop.sources" "/etc/apt/sources.list.d/signal-desktop.sources";
	apt_update && apt_install_package signal-desktop
	if [ $? -ne 0 ]; then log "Failed to install signal-desktop"; sleep 15; exit 1; fi
	log "Signal installed."
fi
