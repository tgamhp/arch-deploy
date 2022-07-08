#!/bin/sh
###############################
# Script Author: Ahmed Maher
###############################

# Sync time online
timedatectl set-ntp true

# Refreshing pacman
pacman -Syyy

# Installing dialog utility
pacman -S dialog


# root password
dialog --insecure --no-cancel --passwordbox "Root password:" 10 50 2>tmp_root_pass
clear
echo root:$(cat tmp_root_pass) | chpasswd
rm tmp_root_pass

# hostname
dialog --no-cancel --inputbox "Hostname:" 10 50 2>tmp_host_name
clear
hostname=$(cat tmp_host_name)
rm tmp_host_name
echo $hostname >> /etc/hostname



# Timezone
ln -sf /usr/share/zoneinfo/Africa/Cairo /etc/localtime

# Synchronizing system clock with hardware clock
hwclock --systohc

# Creating a swapfile
dialog --no-cancel --inputbox "Size of swap file:" 10 50 2>tmp_swap_size
clear
fallocate -l $(cat tmp_swap_size) /swapfile
rm tmp_swap_size

chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo -e "\n/swapfile none swap defaults 0 0" >> /etc/fstab

# Generating locales
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

# Adding the selected locale to locale.conf
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Adding hostnames to hosts file
echo -e "127.0.0.1\tlocalhost" > /etc/hosts
echo -e "::1\t\t\tlocalhost" >> /etc/hosts
echo -e "127.0.1.1\t$hostname.localdomain\t$hostname" >> /etc/hosts



# Setting up the bootloader

# Installing required bootloader packages
pacman -S --needed --noconfirm grub efibootmgr os-prober

# Installing the bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# Enabling os-prober to detect other operating systems (like windows)
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub

# Adding configuration to grub
grub-mkconfig -o /boot/grub/grub.cfg



# Install packages included in pkg.md file
pacman -S --needed --noconfirm $(cat pkg.md | sed '/^\#/d' | sed '/^$/d' | tr '\n' ' ')

# Installing extra packages
#(GUI)Task manager
pip3 install system-monitoring-center
#Img to PDF converter
pip3 install img2pdf

# Allowing kdeconnect through the firewall
ufw allow 1714:1764/udp
ufw allow 1714:1764/tcp
ufw reload

# Enabling Systemd Services
systemctl enable NetworkManager
systemctl enable lightdm

# username
dialog --no-cancel --inputbox "Username:" 10 50 2>tmp_user_name
clear
user_name=$(cat tmp_user_name)
rm tmp_user_name
useradd -mG wheel $user_name

# user password
dialog --insecure --no-cancel --passwordbox "Password:" 10 50 2>tmp_user_password
clear
echo $user_name:$(cat tmp_user_password) | chpasswd
rm tmp_user_password


# Adding the wheel members to sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Return to root
exit
