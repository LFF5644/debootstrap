get_all_timezones(){
	# List all timezones in the system in format 'Europe/Berlin', 'America/New_York', etc.
	find /usr/share/zoneinfo -type f -printf '%P\n' | grep -E '^[A-Z][a-zA-Z_-]+/' | sort
}

IFS=$'\n' timezones=($(get_all_timezones))

entries=()
for zone in "${timezones[@]}"; do
	state="FALSE"
	[ "$NEW_TIMEZONE" == "$zone" ] && state="TRUE"
	#echo "Zeitzone: $zone, State: $state"
	entries+=("$state" "$zone")
done
timezone_columns=(X Zeitzone)
TIMEZONE=$(prompt_list radio "Zeitzone auswählen" "Bitte wählen Sie Ihre Zeitzone aus der Liste aus:" " " timezone_columns entries)
echo "Ausgewählte Zeitzone: $TIMEZONE"
