# template/root$ ln -s ../etc/skel/.bashrc .bashrc

mkdir -p /debootstrap/backup
cp -v /etc/hostname /debootstrap/backup/hostname.bak
cp -v /etc/hosts /debootstrap/backup/hosts.bak

log "set hostname to $NEW_HOSTNAME"
# Sets New System Hostname
echo "$NEW_HOSTNAME" > /etc/hostname
hostname "$NEW_HOSTNAME"

echo -e "# LOCALHOST\n127.0.0.1	$NEW_HOSTNAME" > /etc/hosts
cat /debootstrap/backup/hosts.bak >> /etc/hosts
