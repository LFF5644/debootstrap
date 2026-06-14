# FILE SOURCE /media/storage/Dateien/Dokus/Linux/scripts/debootstrap/template/etc/skel/.bashrc
# ALTERNATIVE FILE SOURCE /media/storage/Dateien/Dokus/Linux/configs/bashrc

HISTCONTROL=ignoreboth # 2x den selben Befehl nicht erlauben xD
HISTTIMEFORMAT="%F %T " # History Format YYYY-MM-DD HH:MM:SS
shopt -s histappend # append to the history file, don't overwrite it
shopt -s checkjobs  # Wenn du versuchst, das Terminal mit exit zu schließen, während noch Jobs im Hintergrund laufen, warnt dich die Bash und listet diese auf.
HISTSIZE=-1
HISTFILESIZE=-1

# update the values of LINES and COLUMNS.
shopt -s checkwinsize

if [ $(id -u) -eq 0 ]; then
	# ROOT SHELL
	# make shell red
	PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]# '
else
	# USER SHELL GREEN
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi
