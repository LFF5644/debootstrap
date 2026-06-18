if contains_package "/debootstrap/pkg-foldingAtHome/00-packages.txt" "folding-at-home-client"; then
	log "Folding@Home is selected for install ..."
	wget --no-check-certificate -O /tmp/fah-client.tar.bz2 "$FAH_DOWNLOAD_CURRENT"
	if [ $? -ne 0 ]; then log "Failed to download Folding@Home"; exit 1; fi
	
	log "extracting downloaded .tar.bz2 ..."
	mkdir -p /opt/fah-client /var/lib/fah-client
	tar -xjf /tmp/fah-client.tar.bz2 --strip-components=1 -C /opt/fah-client/
	if [ $? -ne 0 ]; then log "Failed to extract Folding@Home"; exit 1; fi
	rm /opt/fah-client/fah-client.service /opt/fah-client/LICENCE

	log "export service file & binaries ..."
	fah_cmd_pre_sleep=""
	if [ "$FAH_AUTOSTART_WAIT" != "0" ] && ["$FAH_AUTOSTART" = "true"]; then
		log "adding sleep $FAH_AUTOSTART_WAIT to folding at home service file"
		fah_cmd_pre_sleep="ExecStartPre=sleep $FAH_AUTOSTART_WAIT"
	fi
	echo -e "[Unit]\nDescription=Folding@home Client\nAfter=network.target nss-lookup.target systemd-logind.service\nWants=systemd-logind.service\n\n[Service]\nUser=fah-client$fah_cmd_pre_sleep\nExecStart=/opt/fah-client/fah-client --user=$FAH_USERNAME --team=$FAH_TEAM\nWorkingDirectory=/var/lib/fah-client\nRestart=always\nStandardOutput=null\nKillMode=mixed\nPrivateTmp=yes\nNoNewPrivileges=yes\nProtectSystem=full\nProtectHome=yes\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/fah-client.service
	if [ "$FAH_AUTOSTART" = "true" ]; then
		log "Enable F@H-Client Autostart with systemd..."
		systemctl daemon-reload
		systemctl enable fah-client
	fi

	log "creating user & permissions ..."
	adduser --system fah-client
	chown root:root /opt/fah-client/
	chown fah-client:root /var/lib/fah-client/ -R
	chmod +x /var/lib/fah-client/fah-client

	if [ "$FAH_LIVE_LOGIN" = "true" ]; then
		log "login fah-client LIVE ..."
		sudo -u fah-client bash -c "cd /var/lib/fah-client; exec /opt/fah-client/fah-client '--user=$FAH_USERNAME' '--team=$FAH_TEAM' '--account-token=$SECRET_FAH_TOKEN' '--machine-name=$HOSTNAME'" &
		FAH_PID=$!
		sleep 3
		log "FAH-Client started, waiting for config save, then exit..."
		sleep 4
		log "Closing FAH PID $FAH_PID ..."
		kill $FAH_PID
		ls -lah /var/lib/fah-client/client.db
	fi
	log "Folding at Home Client installation finished."

fi