if contains_package "/debootstrap/base/03-packages-network-tools.txt" "systemd"; then
	log "Enable service: systemd-networkd, systemd-resolved ..."
	systemctl enable systemd-networkd
	systemctl enable systemd-resolved
	if [ "$NETWORK_DHCP" = "false" ]; then 
		log "removing DHCP for NIC ether ..."
		rm /etc/systemd/network/20-wired.network
	else
		log "DHCP shoud be enabled as default."
		ls -lah /etc/systemd/network/20-wired.network
	fi

else
	if [ "$NETWORK_DHCP" = "true" ]; then log "cant enable DHCP! systemd-networkd (package systemd) not found!"; sleep 5; exit; fi
fi
