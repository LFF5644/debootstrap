warning=""
if [ "$INSTALL_DESKTOP_ENVIRONMENT" = "none" ]; then warning="\n\nWARNUNG: Das Installieren von Desktop-Apps wird nicht empfohlen, da keine Benutzer-Oberfläche ausgewählt wurde!";fi
if dialog_question "Desktop-Anwendungen installieren?" "Unter Desktop-Apps oder GTK-Apps verstehe ich alles was mehr als ein Terminal zum ausführen braucht z.B. FireFox oder Chrome, sollen diese installiert werden?$warning" "GTK-Apps auswählen" "Überspringen"; then
	INSTALL_DESKTOP_PACKAGES=true
	echo "INSTALL_DESKTOP_PACKAGES: true"
	if ! PACKAGES_GTK=$(prompt_package_file "template/debootstrap/desktop/10-packages-gtk-apps.txt" "Desktop-App Pakete" "Die folgenden Pakete werden für die Benutzer-Oberfläche on TOP installiert.\nHier kann gerne geändert und angepasst werden, je nach verlangen."); then
		echo "PACKAGES_GTK prompt canceled by user"
		return 1
	fi
	echo "Ausgwählte GTK-Apps: $PACKAGES_GTK"
else
	echo "INSTALL_DESKTOP_PACKAGES: false"
	INSTALL_DESKTOP_PACKAGES=false
fi
