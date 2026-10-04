if dialog_question "Benutzer-Oberfläche?" "Möchten sie eine Benutzer-Oberfläche installieren, dies wird oft auch als DESKTOP-ENVIRONMENT bezeichnet. Andernfalls haben sie nur Zugriff via CLI/Terminal." "Oberfläche auswählen" "nur CLI verwenden"; then
	environments_available_file="prompt/desktop/available-desktop-environments.txt"
	IFS=$'\n' environments_available=($(package_list "$environments_available_file"))
	entities=()
	for pkg in "${environments_available[@]}"; do
		state="FALSE"
		[ "$INSTALL_DESKTOP_ENVIRONMENT" == "$pkg" ] && state="TRUE"
		entities+=("$state" "$pkg")
	done
	columns=(X DESKTOP-ENVIRONMENT)
	if ! INSTALL_DESKTOP_ENVIRONMENT=$(prompt_list radio "Benutzer-Oberfläche auswählen" "Bitte wählen sie die Benutzer-Oberfläche aus,\ndie installiert werden soll:" " " columns entities) || [ "$INSTALL_DESKTOP_ENVIRONMENT" = "" ]; then
		echo "No INSTALL_DESKTOP_ENVIRONMENT selected or user canceled!"
		return 1
	fi
	echo "Ausgewähltes Desktop-Environment: $INSTALL_DESKTOP_ENVIRONMENT"
else
	echo "INSTALL_DESKTOP_ENVIRONMENT: none"
	INSTALL_DESKTOP_ENVIRONMENT=none
fi
