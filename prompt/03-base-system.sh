PACKAGES_BASE=$(prompt_package_file "template/debootstrap/base/03-packages-base.txt" "Basis-System Pakete" "Die folgenden Pakete werden für das Basis-System installiert.\nEs ist nicht empfohlen, diese Pakete zu ändern!")
echo "Ausgewählte Basis-System Pakete: $PACKAGES_BASE"

if dialog_question "CLI-Tools installieren?" "Möchten Sie die CLI-Tools installieren?\nDiese Tools sind für die Arbeit in der Kommandozeile nützlich, aber nicht unbedingt erforderlich." "Installieren" "überspringen"; then
	INSTALL_CLI_TOOLS="true"
	PACKAGES_CLI_TOOLS=$(prompt_package_file "template/debootstrap/base/03-packages-cli-tools.txt" "CLI-Tools Pakete" "Die folgenden Pakete werden für die CLI-Tools installiert.")
	echo "Ausgewählte CLI-Tools Pakete: $PACKAGES_CLI_TOOLS"
else
	INSTALL_CLI_TOOLS="false"
fi

if dialog_question "Chroot-Only Installation?" "Möchten Sie eine Chroot-Only Installation durchführen?\nDies bedeutet, dass das System nur in einer chroot-Umgebung installiert wird.\n\nWICHTIG: Das beeinträchtigt spätere Schritte Beispielsweise Bootloader" "CHROOT ONLY" "Normal"; then
	INSTALL_CHROOT_ONLY="true"
else
	INSTALL_CHROOT_ONLY="false"
fi

if dialog_question "Netzwerk-Tools installieren?" "Möchten Sie die Netzwerk-Tools installieren?\nDiese Tools sind für die Arbeit mit Netzwerken erforderlich, diese können sie überspringen, falls Sie keine Netzwerkkonnektivität benötigen." "Installieren" "überspringen"; then
	INSTALL_NETWORK_TOOLS="true"
	PACKAGES_NETWORK_TOOLS=$(prompt_package_file "template/debootstrap/base/03-packages-network-tools.txt" "Netzwerk-Tools Pakete" "Die folgenden Pakete werden für die Netzwerk-Tools installiert.")
	echo "Ausgewählte Netzwerk-Tools Pakete: $PACKAGES_NETWORK_TOOLS"
	if [ "$INSTALL_CHROOT_ONLY" = "false" ]; then
		PACKAGES_NETWORK_KERNEL=$(prompt_package_file "template/debootstrap/base/03-packages-network-kernel.txt" "Netzwerk-Kernel Pakete" "Die folgenden Pakete werden für die Netzwerk-Kernel installiert.")
		echo "Ausgewählte Netzwerk-Kernel Pakete: $PACKAGES_NETWORK_KERNEL"
	fi
else
	INSTALL_NETWORK_TOOLS="false"
fi
# hack to find out if systemd is in the list of packages to install
echo "$PACKAGES_NETWORK_TOOLS $PACKAGES_NETWORK_KERNEL" | grep "systemd" > /dev/null
# THAT CONDITION DONT WORKS GRRR!
if [ $? -eq 0 ]; then
	if dialog_question "DHCP aktivieren?" "Möchten Sie DHCP für die Netzwerkschnittstellen aktivieren?\nDies ist erforderlich, wenn Sie eine automatische IP-Adresse von einem DHCP-Server erhalten möchten." "DHCP" "Statisch"; then
		NETWORK_DHCP="true"
	else
		NETWORK_DHCP="false"
	fi
else
	NETWORK_DHCP="false"
	dialog_text warning "DHCP nicht verfügbar" "DHCP kann nicht aktiviert werden, da systemd nicht installiert wird, bitte stellen Sie die Netzwerkkonfiguration manuell ein."
fi
