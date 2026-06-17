#!/bin/bash
echo loading config...
source config.env
source secrets.env

PACKAGES_INCLUDE=$(grep -vE '^\s*#|^\s*$' packages-include.txt | tr '\n' ',' | sed 's/,$//')
PACKAGES_EXCLUDE=$(grep -vE '^\s*#|^\s*$' packages-exclude.txt | tr '\n' ',' | sed 's/,$//')
# PACKAGES_INCLUDE=$(grep -vE '^\s*#|^\s*$' packages-include.txt | xargs) # for apt install

echo include packages: $PACKAGES_INCLUDE
echo exclude packages: $PACKAGES_EXCLUDE

time sudo -E debootstrap --arch=amd64 --include="$PACKAGES_INCLUDE" --exclude="$PACKAGES_EXCLUDE" --variant=minbase trixie $target_root http://deb.debian.org/debian

echo strating with template copy...
time sudo cp -rvTL template $target_root
# -L (dereference): Zwingt cp, symbolischen Links zu folgen. Statt der Verknüpfung selbst wird die echte Datei oder der echte Ordner kopiert, auf den der Link zeigt.
# -T: Sorgt wie gewünscht dafür, dass kein neuer Unterordner im Ziel entsteht.

echo mounting / binding to chroot...
sudo mount --bind /dev $target_root/dev
sudo mount --bind /proc $target_root/proc
sudo mount --bind /sys $target_root/sys
sudo mkdir -p $target_root/dev/pts
sudo mount -t devpts devpts $target_root/dev/pts

echo now ruinning in shroot...
time sudo chroot $target_root bash /debootstrap/install.sh

echo finishing! now u cat use the terminal.
sudo chroot $target_root bash

echo unmounting / unbinding ...
sudo umount $target_root/dev/pts
sudo umount $target_root/dev
sudo umount $target_root/proc
sudo umount $target_root/sys
