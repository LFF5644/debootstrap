if [ "$INSTALL_DESKTOP_ENVIRONMENT" = "mate" ]; then
	if ! PACKAGES_MATE=$(prompt_package_file "template/debootstrap/desktop/00-packages-mate.txt" "MATE-Pakete" "Die folgenden Pakete werden für die Benutzer-Oberfläche MATE installiert.\nEs ist nicht empfohlen, diese Pakete zu ändern!"); then
		echo "Packages Mate List dialog weg gemacht!! (user canceled)"
		return 1
	fi
	echo "Ausgewählte MATE-Pakete: $PACKAGES_MATE"
fi
