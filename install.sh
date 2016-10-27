#!/bin/bash

# exit script if return code != 0
set -e

export PATH=/usr/bin:/usr/sbin:$PATH

# update arch repo list with USA mirrors
curl -o /etc/pacman.d/mirrorlist "https://www.archlinux.org/mirrorlist/?country=US&use_mirror_status=on" && sed -i 's/^#//' /etc/pacman.d/mirrorlist

# Get keys and upgrade base to latest
pacman -S --noprogressbar --noconfirm archlinux-keyring
pacman-key --populate
pacman-key --refresh-keys
pacman -Sy --noprogressbar --noconfirm
pacman -S --force openssl --noconfirm
pacman -S pacman --noprogressbar --noconfirm
pacman-db-upgrade
pacman -Syyu --noprogressbar --noconfirm

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

# force re-install of ncurses 6.x with 5.x backwards compatibility (can be removed onced all apps have switched over to ncurses 6.x)
curl -o /tmp/ncurses5-compat-libs-6.0-2-x86_64.pkg.tar.xz -L https://github.com/binhex/arch-packages/releases/download/ncurses5-compat-libs-6.0-2/ncurses5-compat-libs-6.0-2-x86_64.pkg.tar.xz
pacman -U /tmp/ncurses5-compat-libs-6.0-2-x86_64.pkg.tar.xz --noconfirm

# install supervisor
pacman -S supervisor --noconfirm

# cleanup
yes|pacman -Scc
rm -rf /root/*
rm -rf /tmp/*
