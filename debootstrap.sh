#!/bin/bash
echo loading config...
source config.env
source secrets.env

PACKAGES_INCLUDE=$(grep -vE '^\s*#|^\s*$' packages-include.txt | tr '\n' ',' | sed 's/,$//')
PACKAGES_EXCLUDE=$(grep -vE '^\s*#|^\s*$' packages-exclude.txt | tr '\n' ',' | sed 's/,$//')
# PACKAGES_INCLUDE=$(grep -vE '^\s*#|^\s*$' packages-include.txt | xargs) # for apt install

echo include packages: $PACKAGES_INCLUDE
echo exclude packages: $PACKAGES_EXCLUDE
http_proxy=$proxy
https_proxy=$proxy
time sudo -E debootstrap --arch=amd64 --include="$PACKAGES_INCLUDE" --exclude="$PACKAGES_EXCLUDE" --variant=minbase trixie $ROOT_INSTALL http://deb.debian.org/debian
unset PACKAGES_INCLUDE
unset PACKAGES_EXCLUDE
unset http_proxy
unset https_proxy

echo strating with template copy...
time sudo cp -rvTL template $ROOT_INSTALL
# -L (dereference): Zwingt cp, symbolischen Links zu folgen. Statt der Verknüpfung selbst wird die echte Datei oder der echte Ordner kopiert, auf den der Link zeigt.
# -T: Sorgt wie gewünscht dafür, dass kein neuer Unterordner im Ziel entsteht.

echo mounting / binding to chroot...
sudo mount --bind /dev $ROOT_INSTALL/dev
sudo mount --bind /proc $ROOT_INSTALL/proc
sudo mount --bind /sys $ROOT_INSTALL/sys
sudo mount --bind /run $ROOT_INSTALL/run
sudo mkdir -p $ROOT_INSTALL/dev/pts
sudo mount -t devpts devpts $ROOT_INSTALL/dev/pts

echo now ruinning in shroot...
time sudo chroot $ROOT_INSTALL bash /debootstrap/install.sh

echo finishing! now u cat use the terminal.
sudo chroot $ROOT_INSTALL bash

echo unmounting / unbinding ...
sudo umount $ROOT_INSTALL/dev/pts
sudo umount $ROOT_INSTALL/dev
sudo umount $ROOT_INSTALL/proc
sudo umount $ROOT_INSTALL/sys
sudo umount $ROOT_INSTALL/run
