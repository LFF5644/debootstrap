if [ "$INSTALL_DCONF_TEMPLATE" = "false" ]; then
	log "not apply dconf!"
	rm /etc/dconf -rf
else
	log "Install DCONF..."
	apt install -y dconf-cli dconf-service
	log "update dconf db..."
	ls -lah /etc/dconf
	dconf update
	if [ $? -ne 0 ]; then log "Failed DCONF update."; sleep 10; exit 1; fi
	log "DCONF update succsess."
fi
