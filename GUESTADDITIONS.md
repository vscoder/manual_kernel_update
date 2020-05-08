# Virtualbox Guest Additions

By default correct version of VBoxGuestAdditions.iso is distributed with VirtualBox and located at `/usr/share/virtualbox/VBoxGuestAdditions.iso`. So one of the ways is to mount this image by `Vagrantfile` and install Virtualbox Guest Additions from mounted drive.

But I'd like to go over the other way.

First, install necessary packages to build a VBoxGuestAdditions and `dmidecode` to determine VirtualBox version

```shell
# Install dmidecode
sudo yum install -y dmidecode
# Ensure necessary packages are installed
sudo yum install -y gcc binutils make perl bzip2 elfutils-libelf-devel
```

Then get corect VBoxGuestAdditions iso
```shell
cd ~
# Get VBox version (ex: 6.0.20)
VBOX_VERSION=$(dmidecode --oem-string 1 | cut -d_ -f2)
# Download iso
wget https://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso
# Mount iso
sudo mount -o loop ./VBoxGuestAdditions_${VBOX_VERSION}.iso /mnt
# Ensure necessary packages are installed
sudo yum install -y gcc binutils make perl bzip2 elfutils-libelf-devel
# Install VBoxGuestAdditions
sudo /mnt/VBoxLinuxAdditions.run --nox11
```
<details><summary>output</summary>
<p>

```log
Verifying archive integrity... All good.
Uncompressing VirtualBox 6.0.20 Guest Additions for Linux........
VirtualBox Guest Additions installer
Copying additional installer modules ...
Installing additional modules ...
VirtualBox Guest Additions: Starting.
VirtualBox Guest Additions: Building the VirtualBox Guest Additions kernel 
modules.  This may take a while.
VirtualBox Guest Additions: To build modules for other installed kernels, run
VirtualBox Guest Additions:   /sbin/rcvboxadd quicksetup <version>
VirtualBox Guest Additions: or
VirtualBox Guest Additions:   /sbin/rcvboxadd quicksetup all
VirtualBox Guest Additions: Building the modules for kernel 
5.6.11-1.vsc.el7.x86_64.
```
</p>
</details>

Cleanup
```shell
sudo umount /mnt
rm ~/VBoxGuestAdditions*.iso
```

And finally, enable shared folder in vagrant file

`Vagrantfile` line 21, set `disabled` to `false`
```ruby
    config.vm.synced_folder ".", "/vagrant", type: "virtualbox", disabled: false
```
and check it's mounted
```shell
# on host: reload vagrant instance
vagrant reload
vagrant ssh
# on instance: and check content of /vagrant
ll /vagrant
```
<details><summary>output</summary>
<p>

```log
итого 88
drwxrwxr-x. 1 vagrant vagrant  4096 май  7 10:29 assets
-rw-rw-r--. 1 vagrant vagrant 60237 май  7 23:42 BASE.md
-rw-rw-r--. 1 vagrant vagrant  2672 май  7 00:45 DEPRECATED.md
drwxrwxr-x. 1 vagrant vagrant  4096 апр 29 19:39 manual
drwxrwxr-x. 1 vagrant vagrant  4096 апр 30 23:13 packer
-rw-rw-r--. 1 vagrant vagrant    64 апр 29 21:24 README.md
drwxrwxr-x. 1 vagrant vagrant  4096 апр 30 23:15 test
-rw-rw-r--. 1 vagrant vagrant  1356 май  7 23:31 Vagrantfile
```
</p>
</details>

That's it!
