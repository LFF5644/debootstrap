if contains_package "/debootstrap/desktop/15-packages-custom.txt" "lff-picture-selector"; then
	log "Installing lff-picture-selector..."
	apt install nodejs npm -y
	log "Downloading PictureSelectorV2 from GitHub ( https://github.com/LFF5644/PictureSelector ) ..."
	mkdir -p /opt/PictureSelector
	wget -O "/tmp/PictureSelectorV2.zip" "https://github.com/LFF5644/PictureSelector/releases/download/v2.0/PictureSelectorV2.zip"
	unzip "/tmp/PictureSelectorV2.zip" -d /tmp/PictureSelector-unzipped
	cp /tmp/PictureSelector-unzipped/PictureSelectorV2/* /opt/PictureSelector/
	rm -r /tmp/PictureSelectorV2.zip /tmp/PictureSelector-unzipped /opt/PictureSelector/start_windows.vbs
	
	log "Installing PictureSelectorV2 service for background-running & autostart..."
	mkdir -p /etc/systemd/user/
	wget -O /etc/systemd/user/pictureSelectorV2.service "https://github.com/LFF5644/PictureSelector/releases/download/v2.0/pictureSelectorV2.service"

	log "installing node modules for PictureSelectorV2..."
	cd /opt/PictureSelector; npm install; cd -
	
	log "Enabling PictureSelectorV2 (for new users)..."
	mkdir -p /etc/systemd/user/default.target.wants
	ln -s ../pictureSelectorV2.service /etc/systemd/user/default.target.wants/
	log "Installation of lff-picture-selector completed."
fi
