
apt update
apt install --no-install-recommends locales gettext-base -y
#echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
