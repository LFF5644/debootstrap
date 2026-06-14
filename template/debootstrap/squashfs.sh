export INSTALL_DEVICE=$1

#echo kopiere kernel zu boot
#cp $(ls -t /mnt/debian/boot/vmlinuz-* | head -n1) vmlinuz
#cp $(ls -t /mnt/debian/boot/initrd.img-* | head -n1) initrd

apt update
apt install -y grub-efi
apt install -y squashfs-tools live-boot
apt install -y linux-image-amd64 initramfs-tools
apt autoremove --purge
update-initramfs -u
grub-install --target=x86_64-efi --removable --compress=xz -v --core-compress=xz --boot-directory=/boot/ --efi-directory=/boot/

#echo -e "\n\nWant to write grub to $INSTALL_DEVICE are u sure? STRG+C if NOT!! (continue in 10s)"
#sleep 10

#grub-install --target=i386-pc --boot-directory=/boot $INSTALL_DEVICE
