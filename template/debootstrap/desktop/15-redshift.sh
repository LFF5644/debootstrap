if contains_package "/debootstrap/desktop/15-packages-custom.txt" "redshift"; then
	log "Installiere REDSHIFT..."
	apt install redshift -y
	log "Installation von redshift abgeschlossen. Service wird in /etc/systemd/user/redshift.service erstellt..."
	if [ "$TARGET_HARDWARE_TYPE" = "laptop" ]; then night_brightness=1; # Notebooks have a brightness setting itself, so USE IT xD
	elif [ "$TARGET_HARDWARE_TYPE" = "pc" ]; then night_brightness=0.6; fi # DIM PC-Monitor at Night!
	redshift_command="redshift -l 52.5162:13.3777 -t 6500:4000 -b 1:$night_brightness"
	echo -e "[Unit]\nDescription=redshift\nAfter=graphical-session.target\n\n[Service]\nType=exec\nExecStart=$redshift_command\nRestart=always\nRestartSec=10\n\n[Install]\nWantedBy=default.target" > /etc/systemd/user/redshift.service
	ln -s ../redshift.service /etc/systemd/user/default.target.wants/
	log "Installation von redshift abgeschlossen. und im Autostart."
fi