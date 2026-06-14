export LANG=de_DE.UTF-8
export LANGUAGE=de_DE:de
export LC_ALL=de_DE.UTF-8

echo hello from chroot! this is the install script for the new system. it will be executed in chroot, so you can use it like you would use a normal debian system. you can install packages, configure the system, etc. have fun!
echo loading config...
source /debootstrap/config.env


IFS=',' read -ra STEPS <<< "$INSTALL_STEPS"

for STEP in "${STEPS[@]}"; do
    for script in /debootstrap/"$STEP"/*.sh; do
        [ -e "$script" ] || continue
        bash "$script" || { log "Error executing $script"; sleep 60; exit 1; }
    done
done

log "Installation steps completed."
# --- IGNORE ---
exit 0


echo creating user $NEW_USER ...
adduser $NEW_USER --add-extra-groups --home /home/$NEW_USER --comment "$NEW_USER_COMMENT" --shell /bin/bash

# Installing X11 and Desktop stuff
bash /debootstrap/install-desktop-environment.sh

# Installing Grub
bash /debootstrap/install-bootloader.sh

# reload keyboard
udevadm trigger --subsystem-match=input --action=change
setupcon
