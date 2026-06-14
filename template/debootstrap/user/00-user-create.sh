if [ "$NEW_USER" != "none" ]; then
	log "Creating user $NEW_USER ... enter name, password and other infos."
	adduser "$NEW_USER"

	if [ "$NEW_USER_GROUPS" != "none" ]; then
		log "Adding user $NEW_USER to groups: $NEW_USER_GROUPS"
		usermod -aG "$NEW_USER_GROUPS" "$NEW_USER"
		if [ $? -ne 0 ]; then log "Failed to add user $NEW_USER to groups $NEW_USER_GROUPS. Please fix the issue manually."; exit 1; fi
	fi
fi
if [ "$NEW_ROOT_PASSWD" = "true" ]; then
	log "Setting root password... enter new root password."
	passwd root
fi
if [ "$NEW_USER_AUTOLOGIN" = "true" ]; then
	log "Setting up lightdm autologin for user $NEW_USER and session mate..."
	mkdir -p /etc/lightdm/lightdm.conf.d/
	echo -e "[Seat:*]\nautologin-user=$NEW_USER\nautologin-session=mate" > /etc/lightdm/lightdm.conf.d/lightdm-autologin-greeter.conf
fi
