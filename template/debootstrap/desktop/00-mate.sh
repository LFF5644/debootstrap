if [ "$INSTALL_DESKTOP_ENVIRONMENT" = "mate" ]; then
	apt_install "/debootstrap/desktop/00-packages-mate.txt"
fi
