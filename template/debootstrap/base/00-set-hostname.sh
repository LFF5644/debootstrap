
log "set hostname to $NEW_HOSTNAME"
# Sets New System Hostname
echo "$NEW_HOSTNAME" > /etc/hostname
hostname -b "$NEW_HOSTNAME"
