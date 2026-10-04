if [ "$INSTALL_DESKTOP_PACKAGES" = "true" ]; then
	if ! PACKAGES_CUSTOM=$(prompt_package_file "template/debootstrap/desktop/15-packages-custom.txt" "Custom Packete installieren" "Die folgenden Pakete sind Customs,\nalso werden per Skript installiert, da es z.B. Tar.GZ dateien waren.\nDiese können je nach bedarf und Verlangen angepasst werden."); then
		echo "PACKAGES_CUSTOM dialog canceled by User!"
		return 1
	fi
	echo "PACKAGES_CUSTOM: $PACKAGES_CUSTOM"
fi
