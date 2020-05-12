# HW1 Linux kernel update

## [Update from repository](BASE.md)

Here is described an installation of mainline kernel from the ELRepo repsitory and publication of the vagrant box with updated kernel.

https://app.vagrantup.com/vscoder/boxes/centos-7-5

## [Build custom kernel](CUSTOMKERNEL.md)

This article describes a compilation of kernel from sources with config from the ELRepo's kernel package

## [Install VBoxGuestAdditions](GUESTADDITIONS.md)

Here is described the installation process of VirtualBox Guest Additions. It makes shared folders usable.

## [Build and publish box](PACKER.md)

And finally, build vagrant box with packer and publish it on vagrant cloud.

https://app.vagrantup.com/vscoder/boxes/centos-7-5-custom

---

## [Build kernel with vagrant up](VAGRANTPROVISION.md)

There is described the process of build a custom kernel with `vagrant up` provision process.

How to run:
1. `vagratn up` to up vm instance and build a custom kernel
2. `vagrant reload` to automatically enable shared folders

---

## [Some deprecated solutions](DEPRECATED.md)

Here are described some old and wrong ways, but I don't like to lose them.
