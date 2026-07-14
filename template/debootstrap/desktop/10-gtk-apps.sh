if [ "$INSTALL_DESKTOP_PACKAGES" = "true" ]; then
	apt_install "/debootstrap/desktop/10-packages-gtk-apps.txt"
fi
