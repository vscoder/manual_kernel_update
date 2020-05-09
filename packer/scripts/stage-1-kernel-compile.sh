#!/bin/bash

set -eux

echo "Set locale"
export LANG=C

#echo "Install development tools"
#sudo yum groupinstall -y "Development Tools"

echo "Install necessary tools"
sudo yum install -y wget rpm-build redhat-rpm-config
sudo yum install -y asciidoc bc bison elfutils-libelf-devel gcc m4 net-tools newt-devel openssl-devel xmlto audit-libs-devel binutils-devel elfutils-devel java-1.8.0-openjdk-devel libcap-devel numactl-devel "perl(ExtUtils::Embed)" python-devel python3 slang-devel xz-devel zlib-devel ncurses-devel pciutils-devel rsync

echo "Configure rpmbuild directory structure"
cd ~
mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

echo "Install kernel-ml src (nonsrc ^_^) package"
rpm -i https://elrepo.org/linux/kernel/el7/SRPMS/kernel-ml-5.6.11-1.el7.elrepo.nosrc.rpm

echo "Fetch kernel sources"
cd ~/rpmbuild/SOURCES/
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.6.11.tar.xz

echo "Extract kernel sources"
rpmbuild -bp ~/rpmbuild/SPECS/kernel-ml-5.6.spec

echo "Set custom buildid"
cd ~/rpmbuild/SPECS/
cp kernel-ml-5.6.spec kernel-ml-5.6.spec.distrib
# set custom buildid
sed -i.bak 's/#define buildid ./%define buildid .vsc/g' kernel-ml-5.6.spec

echo "Check free space"
df -h

echo "Build"
cd ~/rpmbuild/SPECS/
rpmbuild -bb --target=`uname -m` kernel-ml-5.6.spec

echo "Install new kernel"
cd ~/rpmbuild/RPMS/x86_64/
sudo yum localinstall --skip-broken -y *.rpm

echo "Remove build files"
rm -rf ~/rpmbuild/BUILD/*

echo "Update grub menu"
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo grub2-set-default 0

# Reboot VM
shutdown -r now
