
apt_update
apt_install_package locales gettext-base
if ! grep -q '^de_DE.UTF-8 UTF-8' /etc/locale.gen; then
	echo 'de_DE.UTF-8 UTF-8' >> /etc/locale.gen
fi
locale-gen
