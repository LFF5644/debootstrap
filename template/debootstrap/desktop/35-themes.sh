if [ "$INSTALL_DESKTOP_THEMES" = "true" ]; then
	archive="/debootstrap/desktop/35-themes.tar" # 80 MiB
	list="/debootstrap/desktop/35-themes.txt"
	target="/usr/share/themes"

	log "Extracting GTK themes..."
	time tar -xf "$archive" -C "$target" -T <(tr -d '\r' < "$list" | grep -v '^[[:space:]]*#' | grep -v '^[[:space:]]*$')
	if [ "$?" -ne 0 ]; then log "Error: Failed to extract themes from $archive to $target"; exit 1; fi
	ls -l "$target"
fi
if [ "$SET_GTK_THEME" != "none" ]; then # TODO: none or yes ;-)
	log "Setting Theme: $SET_GTK_THEME" # AI HELPED BY THIS FILE xD https://share.google/aimode/G8DQOu19ZpiK5wn4b
	theme_file="/usr/share/themes/$SET_GTK_THEME/index.theme"
	theme_file_prefix="theme_"
	
	result="$(awk -F= -v p="$theme_file_prefix" '/^\[/ {s=$0} s=="[X-GNOME-Metatheme]" && /=/ {print p$1"=\""$2"\""}' "$theme_file")"
	if [ "$?" -ne 0 ] || [ -z "$result" ]; then log "Error: Failed load config from SET_GTK_THEME '$theme_file', corrupt or not exist! continue..."; sleep 10;return 1; fi
	eval "$result"

	# LOADING overwrites form config
	[ -n "$OVERWRITE_GtkTheme" ] && theme_GtkTheme=$OVERWRITE_GtkTheme
	[ -n "$OVERWRITE_MetacityTheme" ] && theme_MetacityTheme=$OVERWRITE_MetacityTheme
	[ -n "$OVERWRITE_IconTheme" ] && theme_IconTheme=$OVERWRITE_IconTheme
	[ -n "$OVERWRITE_GtkColorScheme" ] && theme_GtkColorScheme=$OVERWRITE_GtkColorScheme
	[ -n "$OVERWRITE_CursorTheme" ] && theme_CursorTheme=$OVERWRITE_CursorTheme
	[ -n "$OVERWRITE_CursorSize" ] && theme_CursorSize=$OVERWRITE_CursorSize

	target_ini=/etc/dconf/db/local.d/80-gtk-themes.ini
	cat << EOF > "$target_ini"
# written by SCRIPT: $SCRIPT

# mate desktop
[org/mate/desktop/interface]
gtk-theme='$theme_GtkTheme'
gtk-color-scheme='$theme_GtkColorScheme'
icon-theme='$theme_IconTheme'

[org/mate/desktop/peripherals/mouse]
cursor-theme='$theme_CursorTheme'
cursor-size='$theme_CursorSize'

# Window Manager
[org/mate/marco/general]
theme='Mint-Y-Dark-Red'

# GTK4
[org/gtk/gtk4/inspector/recorder]
dark='$USE_DARK'
EOF
	log "THEME SETTINGS WRITTEN!"
	ls -lah $target_ini
fi