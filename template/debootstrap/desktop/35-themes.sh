if [ "$INSTALL_DESKTOP_THEMES" = "true" ]; then
	archive="$DOWNLOAD_PREFIX/themes/themes-gtk.tar.xz" # 80 MiB --> 8 MiB
	list="/debootstrap/desktop/35-themes.txt"
	target="/usr/share/themes"

	log "Extracting GTK themes..."
	extract_with_list $archive $target $list
fi
if [ "$INSTALL_ICON_THEMES" = "true" ]; then
	archive="$DOWNLOAD_PREFIX/themes/themes-icon.tar.xz" # 1,80 GiB --> 258 MiB
	list="/debootstrap/desktop/35-themes-icon.txt"
	target="/usr/share/icons"

	log "Extracting GTK Icons..."
	extract_with_list $archive $target $list
fi
if [ "$INSTALL_SOUND_THEMES" = "true" ]; then
	archive="$DOWNLOAD_PREFIX/themes/themes-sound.tar.xz" # 3,2 MiB --> 10,7 MiB
	list="/debootstrap/desktop/35-themes-sound.txt"
	target="/usr/share/sounds"

	log "Extracting GTK Sounds..."
	extract_with_list $archive $target $list
fi
if [ "$NEW_GTK_THEME" != "false" ] && [ -n "$NEW_GTK_THEME" ]; then # TODO: none or yes ;-)
	if [ "$NEW_GTK_THEME" != "default" ]; then
		log "Setting Theme: $NEW_GTK_THEME" # AI HELPED BY THIS FILE xD https://share.google/aimode/G8DQOu19ZpiK5wn4b
		theme_file="/usr/share/themes/$NEW_GTK_THEME/index.theme"
		theme_file_prefix="theme_"
		load_config_section $theme_file $theme_file_prefix X-GNOME-Metatheme
	fi

	# LOADING overwrites form config
	[ -n "$OVERWRITE_GtkTheme" ] && theme_GtkTheme=$OVERWRITE_GtkTheme && log "OVERWRITE_GtkTheme: $OVERWRITE_GtkTheme"
	[ -n "$OVERWRITE_MetacityTheme" ] && theme_MetacityTheme=$OVERWRITE_MetacityTheme && log "OVERWRITE_MetacityTheme: $OVERWRITE_MetacityTheme"
	[ -n "$OVERWRITE_IconTheme" ] && theme_IconTheme=$OVERWRITE_IconTheme && log "OVERWRITE_IconTheme: $OVERWRITE_IconTheme"
	[ -n "$OVERWRITE_GtkColorScheme" ] && theme_GtkColorScheme=$OVERWRITE_GtkColorScheme && log "OVERWRITE_GtkColorScheme: $OVERWRITE_GtkColorScheme"
	[ -n "$OVERWRITE_CursorTheme" ] && theme_CursorTheme=$OVERWRITE_CursorTheme && log "OVERWRITE_CursorTheme: $OVERWRITE_CursorTheme"
	[ -n "$OVERWRITE_CursorSize" ] && theme_CursorSize=$OVERWRITE_CursorSize && log "OVERWRITE_CursorSize: $OVERWRITE_CursorSize"

	target_ini=/etc/dconf/db/local.d/80-themes-gtk.ini
	{
		echo -e "# Written by SCRIPT: $SCRIPT\n"
		echo "# MATE-Desktop"
		echo "[org/mate/desktop/interface]"
		[ -n "$theme_GtkTheme" ] && echo "gtk-theme='$theme_GtkTheme'"
		[ -n "$theme_GtkColorScheme" ] && echo "gtk-color-scheme='$theme_GtkColorScheme'"
		[ -n "$theme_IconTheme" ] && echo "icon-theme='$theme_IconTheme'"
		echo
		echo "[org/mate/desktop/peripherals/mouse]"
		[ -n "$theme_CursorTheme" ] && echo "cursor-theme='$theme_CursorTheme'"
		[ -n "$theme_CursorSize" ] && echo "cursor-size='$theme_CursorSize'"
		echo
		echo "# Window Manager"
		echo "[org/mate/marco/general]"
		[ -n "$theme_GtkTheme" ] && echo "theme='$theme_GtkTheme'"
		cat << EOF
# GTK4
[org/gtk/gtk4/inspector/recorder]
dark='$USE_DARK'
EOF

	} > "$target_ini"
	if [ "$?" -ne 0 ]; then log "Error: can not write to file '$target_ini'. continue...."; sleep 10; return 1; fi
	ls -lah $target_ini
fi
if [ "$NEW_SOUND_THEME" != "false" ] && [ -n "$NEW_SOUND_THEME" ]; then # TODO: none or yes ;-)
	if [ "$NEW_SOUND_THEME" == "none" ]; then
		log "disable sound theme"
		NEW_SOUND_THEME="__no_sounds";
		ENABLE_SOUNDS_EVENT=false
		ENABLE_SOUNDS_FEEDBACK=false
	else
		log "sound theme '$NEW_SOUND_THEME' will set"
	fi
	target_ini=/etc/dconf/db/local.d/80-themes-sound.ini
	cat << EOF > "$target_ini"
# Written by SCRIPT: $SCRIPT

# MATE-Desktop
[org/mate/desktop/sound]
event-sounds='$ENABLE_SOUNDS_EVENT'
input-feedback-sounds='$ENABLE_SOUNDS_FEEDBACK'
theme-name='$NEW_SOUND_THEME'
EOF
	if [ "$?" -ne 0 ]; then log "Error: can not write to file '$target_ini'. continue...."; sleep 10; return 1; fi
	ls -lah $target_ini
fi
