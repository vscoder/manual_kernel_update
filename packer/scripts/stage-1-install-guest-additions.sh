#!/bin/bash

set -eux

echo "Install dmidecode and other necessary tools"
sudo yum install -y dmidecode wget

echo "Ensure other necessary packages are installed"
sudo yum install -y gcc binutils make perl bzip2 elfutils-libelf-devel

echo "Get VBox version (ex: 6.0.20)"
VBOX_VERSION=$(dmidecode --oem-string 1 | cut -d_ -f2)

echo "Download iso"
cd ~
wget https://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso

echo "Mount iso"
sudo mount -o loop ./VBoxGuestAdditions_${VBOX_VERSION}.iso /mnt

echo "Install VBoxGuestAdditions"
sudo /mnt/VBoxLinuxAdditions.run --nox11

echo "Unmount iso"
sudo umount /mnt

echo "Remove iso"
rm ~/VBoxGuestAdditions*.iso

# Reboot VM (except vagrant provisioner)
set +u
if [ "$PROVISIONER" != "vagrant" ]
then
    echo "Reboot"
    shutdown -r now
fi
