if [ "$INSTALL_DESKTOP_THEMES" = "true" ]; then
	archive="/debootstrap/desktop/35-themes.tar" # 80 MiB
	list="/debootstrap/desktop/35-themes.txt"
	target="/usr/share/themes"

	log "Extracting GTK themes..."
	time tar -xf "$archive" -C "$target" -T <(tr -d '\r' < "$list" | grep -v '^[[:space:]]*#' | grep -v '^[[:space:]]*$')
	if [ "$?" -ne 0 ]; then log "Error: Failed to extract themes from $archive to $target"; exit 1; fi
	ls -l "$target"
fi
