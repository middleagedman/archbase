#!/bin/bash

# exit script if return code != 0
set -e

export PATH=/usr/bin:/usr/sbin:$PATH

# update arch repo list with USA mirrors
curl -so /etc/pacman.d/mirrorlist "https://www.archlinux.org/mirrorlist/?country=US&use_mirror_status=on" && sed -i 's/^#//' /etc/pacman.d/mirrorlist

# Get keys and upgrade base to latest
pacman-key --populate
pacman-key --refresh-keys
pacman -Sy --noprogressbar --noconfirm
pacman -S --force --noconfirm openssl
pacman -S --noprogressbar --noconfirm archlinux-keyring
pacman -S --noprogressbar --noconfirm pacman
pacman-db-upgrade 
pacman -Su --noprogressbar --noconfirm

# set locale
echo en_US.UTF-8 UTF-8 > /etc/locale.gen
locale-gen
echo LANG="en_US.UTF-8" > /etc/locale.conf

# add user "nobody" to primary group "users" (will remove any other group membership)
usermod -g users nobody

# add user "nobody" to secondary group "nobody" (will retain primary membership)
usermod -a -G nobody nobody

# setup env for user nobody
mkdir -p /home/nobody
chown -R nobody:users /home/nobody
chmod -R 775 /home/nobody

# install supervisor
pacman -S supervisor --noconfirm

# cleanup
yes|pacman -Scc
rm -rf /root/*
rm -rf /tmp/*
