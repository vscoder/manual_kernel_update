# Update from repository

- [Update from repository](#update-from-repository)
  - [Preparation](#preparation)
  - [Get up VM instance](#get-up-vm-instance)
  - [Update kernel from elrepo-kernel](#update-kernel-from-elrepo-kernel)
    - [Add elrepo-kernel repository](#add-elrepo-kernel-repository)
    - [Install lates available kernel version.](#install-lates-available-kernel-version)
    - [List installed kernel packages](#list-installed-kernel-packages)
  - [Update GRUB config](#update-grub-config)
    - [Update GRUB config](#update-grub-config-1)
    - [Reboot for manual kernel selection](#reboot-for-manual-kernel-selection)
    - [Set new kernel used by default](#set-new-kernel-used-by-default)
    - [Final reboot](#final-reboot)

## Preparation

Already installed these utilites:

- `VirtualBox 6.0.20r137117`
- `Vagrant 2.2.6`
- `packer 1.4.4`
- `git version 2.17.1`

This repo was forked and cloned, as described in this [instruction](manual/manual.md)


## Get up VM instance

`vagrant up`

<details><summary>output</summary>
<p>

```log
==> vagrant: A new version of Vagrant is available: 2.2.7 (installed version: 2.2.6)!
==> vagrant: To upgrade visit: https://www.vagrantup.com/downloads.html

Bringing machine 'kernel-update' up with 'virtualbox' provider...
==> kernel-update: Box 'centos/7' could not be found. Attempting to find and install...
    kernel-update: Box Provider: virtualbox
    kernel-update: Box Version: >= 0
==> kernel-update: Loading metadata for box 'centos/7'
    kernel-update: URL: https://vagrantcloud.com/centos/7
==> kernel-update: Adding box 'centos/7' (v1905.1) for provider: virtualbox
    kernel-update: Downloading: https://vagrantcloud.com/centos/boxes/7/versions/1905.1/providers/virtualbox.box
    kernel-update: Download redirected to host: cloud.centos.org
==> kernel-update: Successfully added box 'centos/7' (v1905.1) for 'virtualbox'!
==> kernel-update: Importing base box 'centos/7'...
==> kernel-update: Matching MAC address for NAT networking...
==> kernel-update: Checking if box 'centos/7' version '1905.1' is up to date...
==> kernel-update: Setting the name of the VM: manual_kernel_update_kernel-update_1588190122634_91716
==> kernel-update: Clearing any previously set network interfaces...
==> kernel-update: Preparing network interfaces based on configuration...
    kernel-update: Adapter 1: nat
==> kernel-update: Forwarding ports...
    kernel-update: 22 (guest) => 2222 (host) (adapter 1)
==> kernel-update: Running 'pre-boot' VM customizations...
==> kernel-update: Booting VM...
==> kernel-update: Waiting for machine to boot. This may take a few minutes...
    kernel-update: SSH address: 127.0.0.1:2222
    kernel-update: SSH username: vagrant
    kernel-update: SSH auth method: private key
    kernel-update: 
    kernel-update: Vagrant insecure key detected. Vagrant will automatically replace
    kernel-update: this with a newly generated keypair for better security.
    kernel-update: 
    kernel-update: Inserting generated public key within guest...
    kernel-update: Removing insecure key from the guest if it's present...
    kernel-update: Key inserted! Disconnecting and reconnecting using new SSH key...
==> kernel-update: Machine booted and ready!
==> kernel-update: Checking for guest additions in VM...
    kernel-update: No guest additions were detected on the base box for this VM! Guest
    kernel-update: additions are required for forwarded ports, shared folders, host only
    kernel-update: networking, and more. If SSH fails on this machine, please install
    kernel-update: the guest additions and repackage the box to continue.
    kernel-update: 
    kernel-update: This is not an error message; everything may continue to work properly,
    kernel-update: in which case you may ignore this message.
==> kernel-update: Setting hostname...
```
</p>
</details>

Get current VM kernel version

```shell
vagrant ssh
[vagrant@kernel-update ~]$ uname -r
3.10.0-957.12.2.el7.x86_64
```

## Update kernel from elrepo-kernel

### Add elrepo-kernel repository

```shell
[vagrant@kernel-update ~]$ rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
[vagrant@kernel-update ~]$ sudo yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
```

<details><summary>output</summary>
<p>

```log
Failed to set locale, defaulting to C
Loaded plugins: fastestmirror
elrepo-release-7.el7.elrepo.noarch.rpm                                                                                               | 8.5 kB  00:00:00     
Examining /var/tmp/yum-root-MidEB2/elrepo-release-7.el7.elrepo.noarch.rpm: elrepo-release-7.0-4.el7.elrepo.noarch
Marking /var/tmp/yum-root-MidEB2/elrepo-release-7.el7.elrepo.noarch.rpm to be installed
Resolving Dependencies
--> Running transaction check
---> Package elrepo-release.noarch 0:7.0-4.el7.elrepo will be installed
--> Finished Dependency Resolution

Dependencies Resolved

============================================================================================================================================================
 Package                          Arch                     Version                              Repository                                             Size
============================================================================================================================================================
Installing:
 elrepo-release                   noarch                   7.0-4.el7.elrepo                     /elrepo-release-7.el7.elrepo.noarch                   5.0 k

Transaction Summary
============================================================================================================================================================
Install  1 Package

Total size: 5.0 k
Installed size: 5.0 k
Downloading packages:
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : elrepo-release-7.0-4.el7.elrepo.noarch                                                                                                   1/1 
  Verifying  : elrepo-release-7.0-4.el7.elrepo.noarch                                                                                                   1/1 

Installed:
  elrepo-release.noarch 0:7.0-4.el7.elrepo                                                                                                                  

Complete!
```
</p>
</details>

There are two kernel versions:
- `kernel-ml` - mainline kernel. Mostly fresh stable version.
- `kernel-lt` - LTS version. Less fresh, but more stable version with enchanced support time.

### Install lates available kernel version.

NOTE: We need to `--enablerepo elrepo-kernel` to install kernel package from corresponding repository
```shell
sudo yum --enablerepo elrepo-kernel install kernel-ml -y
```
<details><summary>output</summary>
<p>

```log
Failed to set locale, defaulting to C
Loaded plugins: fastestmirror
Determining fastest mirrors
 * base: mirror.yandex.ru
 * elrepo: mirrors.colocall.net
 * elrepo-kernel: mirrors.colocall.net
 * extras: mirror.corbina.net
 * updates: centos-mirror.rbc.ru
base                                                                                                                                 | 3.6 kB  00:00:00     
elrepo                                                                                                                               | 2.9 kB  00:00:00     
elrepo-kernel                                                                                                                        | 2.9 kB  00:00:00     
extras                                                                                                                               | 2.9 kB  00:00:00     
updates                                                                                                                              | 2.9 kB  00:00:00     
(1/6): base/7/x86_64/group_gz                                                                                                        | 153 kB  00:00:00     
(2/6): extras/7/x86_64/primary_db                                                                                                    | 190 kB  00:00:00     
(3/6): updates/7/x86_64/primary_db                                                                                                   | 165 kB  00:00:00     
(4/6): elrepo/primary_db                                                                                                             | 478 kB  00:00:00     
(5/6): base/7/x86_64/primary_db                                                                                                      | 6.1 MB  00:00:00     
(6/6): elrepo-kernel/primary_db                                                                                                      | 1.9 MB  00:00:00     
Resolving Dependencies
--> Running transaction check
---> Package kernel-ml.x86_64 0:5.6.8-1.el7.elrepo will be installed
--> Finished Dependency Resolution

Dependencies Resolved

============================================================================================================================================================
 Package                           Arch                           Version                                       Repository                             Size
============================================================================================================================================================
Installing:
 kernel-ml                         x86_64                         5.6.8-1.el7.elrepo                            elrepo-kernel                          49 M

Transaction Summary
============================================================================================================================================================
Install  1 Package

Total download size: 49 M
Installed size: 222 M
Downloading packages:
warning: /var/cache/yum/x86_64/7/elrepo-kernel/packages/kernel-ml-5.6.8-1.el7.elrepo.x86_64.rpm: Header V4 DSA/SHA1 Signature, key ID baadae52: NOKEY00 ETA 
Public key for kernel-ml-5.6.8-1.el7.elrepo.x86_64.rpm is not installed
kernel-ml-5.6.8-1.el7.elrepo.x86_64.rpm                                                                                              |  49 MB  00:00:17     
Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
Importing GPG key 0xBAADAE52:
 Userid     : "elrepo.org (RPM Signing Key for elrepo.org) <secure@elrepo.org>"
 Fingerprint: 96c0 104f 6315 4731 1e0b b1ae 309b c305 baad ae52
 Package    : elrepo-release-7.0-4.el7.elrepo.noarch (installed)
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : kernel-ml-5.6.8-1.el7.elrepo.x86_64                                                                                                      1/1 
  Verifying  : kernel-ml-5.6.8-1.el7.elrepo.x86_64                                                                                                      1/1 

Installed:
  kernel-ml.x86_64 0:5.6.8-1.el7.elrepo                                                                                                                     

Complete!
```
</p>
</details>

As we can see, `kernel-ml.x86_64 0:5.6.8-1.el7.elrepo` is installed.

### List installed kernel packages

```shell
[vagrant@kernel-update ~]$ yum list kernel*
```
<details><summary>output</summary>
<p>

```log
Failed to set locale, defaulting to C
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.reconn.ru
 * elrepo: mirrors.colocall.net
 * extras: mirror.reconn.ru
 * updates: centos-mirror.rbc.ru
Installed Packages
kernel.x86_64                                                              3.10.0-957.12.2.el7                                              @koji-override-1
kernel-ml.x86_64                                                           5.6.8-1.el7.elrepo                                               @elrepo-kernel  
kernel-tools.x86_64                                                        3.10.0-957.12.2.el7                                              @koji-override-1
kernel-tools-libs.x86_64                                                   3.10.0-957.12.2.el7                                              @koji-override-1
Available Packages
kernel.x86_64                                                              3.10.0-1127.el7                                                  base            
kernel-abi-whitelists.noarch                                               3.10.0-1127.el7                                                  base            
kernel-debug.x86_64                                                        3.10.0-1127.el7                                                  base            
kernel-debug-devel.x86_64                                                  3.10.0-1127.el7                                                  base            
kernel-devel.x86_64                                                        3.10.0-1127.el7                                                  base            
kernel-doc.noarch                                                          3.10.0-1127.el7                                                  base            
kernel-headers.x86_64                                                      3.10.0-1127.el7                                                  base            
kernel-tools.x86_64                                                        3.10.0-1127.el7                                                  base            
kernel-tools-libs.x86_64                                                   3.10.0-1127.el7                                                  base            
kernel-tools-libs-devel.x86_64                                             3.10.0-1127.el7                                                  base
```
</p>
</details>


Next we need to update GRUB bootloader config.

## Update GRUB config

The Plan:

1. Update GRUB config file
2. Reboot and manual select new kernel in GRUB boot menu (ensure new kernel is bootable)
3. Set new kernel used by default
4. Final reboot to ensure GRUB config is correct

### Update GRUB config

```shell
[vagrant@kernel-update ~]$ sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```
<details><summary>output</summary>
<p>

```log
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-5.6.8-1.el7.elrepo.x86_64
Found initrd image: /boot/initramfs-5.6.8-1.el7.elrepo.x86_64.img
Found linux image: /boot/vmlinuz-3.10.0-957.12.2.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-957.12.2.el7.x86_64.img
done
```
</p>
</details>

### Reboot for manual kernel selection

Not applicable for Vagrant

### Set new kernel used by default

List menu entrys
```shell
[vagrant@kernel-update ~]$ sudo awk -F\' '/menuentry / {print $2}' /boot/grub2/grub.cfg
```
```log
CentOS Linux (5.6.8-1.el7.elrepo.x86_64) 7 (Core)
CentOS Linux (3.10.0-957.12.2.el7.x86_64) 7 (Core)
```

Set new kernel as default
```shell
[vagrant@kernel-update ~]$ sudo grub2-set-default 0
```

### Final reboot

Reboot
```shell
[vagrant@kernel-update ~]$ sudo reboot
```

Connect after reboot
```shell
vagrant ssh
```
```log
Last login: Wed Apr 29 19:59:09 2020 from 10.0.2.2
[vagrant@kernel-update ~]$
```

Check kernel version
```shell
[vagrant@kernel-update ~]$ uname -r
```
```log
5.6.8-1.el7.elrepo.x86_64
```
