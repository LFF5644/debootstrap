if [ "$INSTALL_DESKTOP_TOOLS" = "true" ]; then
	apt_install "/debootstrap/desktop/10-packages-gtk-apps.txt"
fi
