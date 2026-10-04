columns=(X Gerät Beschreibung)
entries=()
entries+=(FALSE pc "Fester Standort")
entries+=(FALSE laptop "Dynamischer Standort")
if ! TARGET_HARDWARE_TYPE=$(prompt_list radio "Installations Ziel?" "Wo drauf soll das Linux angepasst werden?" " " columns entries) || [ "$TARGET_HARDWARE_TYPE" = "" ];  then
	echo "GRRR: User Cancheled or did not fill the TARGET_HARDWARE_TYPE prompt!"
	return 1
fi
echo "TARGET_HARDWARE_TYPE: $TARGET_HARDWARE_TYPE"
