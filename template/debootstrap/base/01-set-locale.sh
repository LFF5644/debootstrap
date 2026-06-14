
apt update
apt install --no-install-recommends locales gettext-base -y
if ! grep -q '^de_DE.UTF-8 UTF-8' /etc/locale.gen; then
	echo 'de_DE.UTF-8 UTF-8' >> /etc/locale.gen
fi
locale-gen
