# hacky way: 'dpkg-reconfigure tzdata' or 'tzselect'
log "Updating timezone to: $NEW_TIMEZONE ..."
ls -lh /usr/share/zoneinfo/$NEW_TIMEZONE /etc/localtime
rm /etc/localtime

ln /usr/share/zoneinfo/$NEW_TIMEZONE /etc/localtime
log "Timezone Updated! ($NEW_TIMEZONE)"
ls -lh /usr/share/zoneinfo/$NEW_TIMEZONE /etc/localtime
