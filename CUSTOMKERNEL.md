# Custom kernel

- [Custom kernel](#custom-kernel)
  - [Preparation](#preparation)
    - [On host](#on-host)
    - [Install tools](#install-tools)
    - [Get kernel sources](#get-kernel-sources)
  - [Installation](#installation)
    - [Configure (skipped)](#configure-skipped)
    - [Build](#build)
    - [Install](#install)
    - [Grub](#grub)

Documentation: https://wiki.centos.org/HowTos/Custom_Kernel (But I don't want old kernel, give me new!)

## Preparation

### On host

```shell
# On host OS, uninstall vagrant-vbguest plugin (it needs only if that plugin is installed present)
vagrant plugin uninstall vagrant-vbguest
# destroy current vagrant instances
vagrant destroy
```

Update vagrant instance resources in [Vagrantfile](Vagrantfile), set `:cpus => 8` and `:memory => 8196`Mb

Up and connect to vagrant instance
```shell
vagrant up
vagrant ssh
```

### Install tools
```shell
# Install common tools
sudo yum install wget
# Install development tools
sudo yum groupinstall "Development Tools"
```
[output](assets/groupinstall-dev-tools.log)

### Get kernel sources

This link helps: https://elrepo.org/bugs/view.php?id=870&nbn=1

Let's explore elrepo mirror https://elrepo.org/linux/ and try to find src package...
Got it! Download kernel-ml src (nosrc ^_^) rpm from https://elrepo.org/linux/kernel/el7/SRPMS/kernel-ml-5.6.11-1.el7.elrepo.nosrc.rpm

```shell
# Go to home directory
cd
# Create a rpmbuild directory structure
mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
# and configure rpmbuild to use it
echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros
# Install kernel-ml src (nonsrc ^_^) package
rpm -i https://elrepo.org/linux/kernel/el7/SRPMS/kernel-ml-5.6.11-1.el7.elrepo.nosrc.rpm
```
<details><summary>output</summary>
<p>

```log
rpm -i https://elrepo.org/linux/kernel/el7/SRPMS/kernel-ml-5.6.11-1.el7.elrepo.nosrc.rpm
warning: user ajb does not exist - using root
warning: group ajb does not exist - using root
warning: user ajb does not exist - using root
warning: group ajb does not exist - using root
warning: user ajb does not exist - using root
warning: group ajb does not exist - using root
warning: user ajb does not exist - using root
warning: group ajb does not exist - using root
```
</p>
</details>

Check result
```shell
cd ~/rpmbuild
tree .
```
```log
tree
.
|-- BUILD
|-- BUILDROOT
|-- RPMS
|-- SOURCES
|   |-- config-5.6.11-x86_64
|   |-- cpupower.config
|   `-- cpupower.service
|-- SPECS
|   `-- kernel-ml-5.6.spec
`-- SRPMS

6 directories, 4 files
```

Get kernel tarball from kernel.org
```shell
cd ~/rpmbuild/SOURCES/
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.6.11.tar.xz
```

Extract sources (and apply patches if present)
```shell
rpmbuild -bp ~/rpmbuild/SPECS/kernel-ml-5.6.spec
```
<details><summary>OOPS...</summary>
<p>

```log
error: Failed build dependencies:
        asciidoc is needed by kernel-ml-5.6.11-1.el7.x86_64
        bc is needed by kernel-ml-5.6.11-1.el7.x86_64
        elfutils-libelf-devel is needed by kernel-ml-5.6.11-1.el7.x86_64
        net-tools is needed by kernel-ml-5.6.11-1.el7.x86_64
        newt-devel is needed by kernel-ml-5.6.11-1.el7.x86_64
        openssl-devel is needed by kernel-ml-5.6.11-1.el7.x86_64
        audit-libs-devel is needed by kernel-ml-5.6.11-1.el7.x86_64
        binutils-devel is needed by kernel-ml-5.6.11-1.el7.x86_64
        elfutils-devel is needed by kernel-ml-5.6.11-1.el7.x86_64
        java-1.8.0-openjdk-devel is needed by kernel-ml-5.6.11-1.el7.x86_64
        libcap-devel is needed by kernel-ml-5.6.11-1.el7.x86_64
        numactl-devel is needed by kernel-ml-5.6.11-1.el7.x86_64
        perl(ExtUtils::Embed) is needed by kernel-ml-5.6.11-1.el7.x86_64
        python-devel is needed by kernel-ml-5.6.11-1.el7.x86_64
        python3 is needed by kernel-ml-5.6.11-1.el7.x86_64
        slang-devel is needed by kernel-ml-5.6.11-1.el7.x86_64
        xz-devel is needed by kernel-ml-5.6.11-1.el7.x86_64
        ncurses-devel is needed by kernel-ml-5.6.11-1.el7.x86_64
        pciutils-devel is needed by kernel-ml-5.6.11-1.el7.x86_64
```
</p>
</details>

Let's install missing packages
```shell
sudo yum install -y asciidoc bc elfutils-libelf-devel net-tools newt-devel openssl-devel audit-libs-devel binutils-devel elfutils-devel java-1.8.0-openjdk-devel libcap-devel numactl-devel "perl(ExtUtils::Embed)" python-devel python3 slang-devel xz-devel ncurses-devel pciutils-devel
```
[output](assets/install-missing.log)

Extract sources, second attempt
```shell
rpmbuild -bp ~/rpmbuild/SPECS/kernel-ml-5.6.spec
```
Success!
<details><summary>output</summary>
<p>

```log
Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.parNha+ umask 022
+ cd /home/vagrant/rpmbuild/BUILD
+ cd /home/vagrant/rpmbuild/BUILD
+ rm -rf kernel-ml-5.6.11
+ /usr/bin/mkdir -p kernel-ml-5.6.11
+ cd kernel-ml-5.6.11
+ /usr/bin/xz -dc /home/vagrant/rpmbuild/SOURCES/linux-5.6.11.tar.xz
+ /usr/bin/tar -xf -
+ STATUS=0
+ '[' 0 -ne 0 ']'
+ /usr/bin/chmod -Rf a+rX,u+w,g-w,o-w .
+ /usr/bin/mv linux-5.6.11 linux-5.6.11-1.el7.x86_64
+ pushd linux-5.6.11-1.el7.x86_64
+ /usr/bin/find -name '.[a-z]*'
+ xargs --no-run-if-empty /usr/bin/rm -rf
+ /usr/bin/cp /home/vagrant/rpmbuild/SOURCES/config-5.6.11-x86_64 .
+ for C in 'config-*-x86_64*'
+ /usr/bin/cp config-5.6.11-x86_64 .config
+ /usr/bin/make -s ARCH=x86_64 listnewconfig
+ grep -E '^CONFIG_'
+ true
+ '[' -s .newoptions ']'
+ /usr/bin/rm -f .newoptions
+ popd
+ exit 0
```
</p>
</details>

Check sources size (Just for fun:)
```shell
du -sm ~/rpmbuild/BUILD/kernel-ml-5.6.11/linux-5.6.11-1.el7.x86_64/
```
```log
1020    /home/vagrant/rpmbuild/BUILD/kernel-ml-5.6.11/linux-5.6.11-1.el7.x86_64/
```

## Installation

### Configure (skipped)

NOTE: Only for custom kernel configuration
Copy old config
```shell
# backup distribution config
cd ~/rpmbuild/SOURCES/
mv config-5.6.11-x86_64 config-5.6.11-x86_64.distrib
cd ~/rpmbuild/BUILD/kernel-ml-5.6.11/linux-5.6.11-1.el7.x86_64/
# backup original .config
mv .config .config.dist
# copy old config to .config
cp /boot/config-`uname -r` .config
# Adopt old configuration
yes "" | make oldconfig
cp ./config ~/rpmbuild/SOURCES/config-5.6.11-x86_64
```
`make oldconfig` command [output](assets/make-oldconfig.log)

But we didn't do that step ^_^

And we didn't do `make menuconfig`. Not in this time. A sleeping is though important...


### Build

Change buildid in spec
```shell
cd ~/rpmbuild/SPECS/
cp kernel-ml-5.6.spec kernel-ml-5.6.spec.distrib
# set custom buildid
sed -i.bak 's/#define buildid ./%define buildid .vsc/g' kernel-ml-5.6.spec
```

```shell
cd ~/rpmbuild/SPECS/
rpmbuild -bb --target=`uname -m` kernel-ml-5.6.spec
```
[output](assets/kernel-build-out.log)

A sleeping must be awesome...

Finished
```log
Записан: /home/vagrant/rpmbuild/RPMS/x86_64/kernel-ml-5.6.11-1.vsc.el7.x86_64.rpm
Записан: /home/vagrant/rpmbuild/RPMS/x86_64/kernel-ml-devel-5.6.11-1.vsc.el7.x86_64.rpm
Записан: /home/vagrant/rpmbuild/RPMS/x86_64/kernel-ml-headers-5.6.11-1.vsc.el7.x86_64.rpm
Записан: /home/vagrant/rpmbuild/RPMS/x86_64/perf-5.6.11-1.vsc.el7.x86_64.rpm
Записан: /home/vagrant/rpmbuild/RPMS/x86_64/python-perf-5.6.11-1.vsc.el7.x86_64.rpm
Записан: /home/vagrant/rpmbuild/RPMS/x86_64/kernel-ml-tools-5.6.11-1.vsc.el7.x86_64.rpm
Записан: /home/vagrant/rpmbuild/RPMS/x86_64/kernel-ml-tools-libs-5.6.11-1.vsc.el7.x86_64.rpm
Записан: /home/vagrant/rpmbuild/RPMS/x86_64/kernel-ml-tools-libs-devel-5.6.11-1.vsc.el7.x86_64.rpm
```

### Install

```shell
cd ~/rpmbuild/RPMS/x86_64/
sudo yum localinstall --skip-broken -y *.rpm
```
There are some conflicts, but kernel is installed.
<details><summary>output</summary>
<p>

```log
Loaded plugins: fastestmirror
Examining kernel-ml-5.6.11-1.vsc.el7.x86_64.rpm: kernel-ml-5.6.11-1.vsc.el7.x86_64
Marking kernel-ml-5.6.11-1.vsc.el7.x86_64.rpm to be installed
Examining kernel-ml-devel-5.6.11-1.vsc.el7.x86_64.rpm: kernel-ml-devel-5.6.11-1.vsc.el7.x86_64
Marking kernel-ml-devel-5.6.11-1.vsc.el7.x86_64.rpm as an update to kernel-ml-devel-5.6.11-1.el7.elrepo.x86_64
Examining kernel-ml-headers-5.6.11-1.vsc.el7.x86_64.rpm: kernel-ml-headers-5.6.11-1.vsc.el7.x86_64
Marking kernel-ml-headers-5.6.11-1.vsc.el7.x86_64.rpm to be installed
Examining kernel-ml-tools-5.6.11-1.vsc.el7.x86_64.rpm: kernel-ml-tools-5.6.11-1.vsc.el7.x86_64
Marking kernel-ml-tools-5.6.11-1.vsc.el7.x86_64.rpm to be installed
Examining kernel-ml-tools-libs-5.6.11-1.vsc.el7.x86_64.rpm: kernel-ml-tools-libs-5.6.11-1.vsc.el7.x86_64
Marking kernel-ml-tools-libs-5.6.11-1.vsc.el7.x86_64.rpm to be installed
Examining kernel-ml-tools-libs-devel-5.6.11-1.vsc.el7.x86_64.rpm: kernel-ml-tools-libs-devel-5.6.11-1.vsc.el7.x86_64
Marking kernel-ml-tools-libs-devel-5.6.11-1.vsc.el7.x86_64.rpm to be installed
Examining perf-5.6.11-1.vsc.el7.x86_64.rpm: perf-5.6.11-1.vsc.el7.x86_64
Marking perf-5.6.11-1.vsc.el7.x86_64.rpm to be installed
Examining python-perf-5.6.11-1.vsc.el7.x86_64.rpm: python-perf-5.6.11-1.vsc.el7.x86_64
Marking python-perf-5.6.11-1.vsc.el7.x86_64.rpm as an update to python-perf-3.10.0-957.12.2.el7.x86_64
Resolving Dependencies
--> Running transaction check
---> Package kernel-ml.x86_64 0:5.6.11-1.vsc.el7 will be installed
---> Package kernel-ml-devel.x86_64 0:5.6.11-1.vsc.el7 will be installed
---> Package kernel-ml-headers.x86_64 0:5.6.11-1.vsc.el7 will be installed
---> Package kernel-ml-tools.x86_64 0:5.6.11-1.vsc.el7 will be installed
---> Package kernel-ml-tools-libs.x86_64 0:5.6.11-1.vsc.el7 will be installed
---> Package kernel-ml-tools-libs-devel.x86_64 0:5.6.11-1.vsc.el7 will be installed
---> Package perf.x86_64 0:5.6.11-1.vsc.el7 will be installed
---> Package python-perf.x86_64 0:3.10.0-957.12.2.el7 will be updated
---> Package python-perf.x86_64 0:5.6.11-1.vsc.el7 will be an update
--> Processing Conflict: kernel-ml-headers-5.6.11-1.vsc.el7.x86_64 conflicts kernel-headers < 5.6.11-1.vsc.el7
Loading mirror speeds from cached hostfile
 * base: mirror.sale-dedic.com
 * elrepo: mirrors.colocall.net
 * extras: mirror.sale-dedic.com
 * updates: mirror.sale-dedic.com
No package matched to upgrade: kernel-ml-headers
--> Processing Conflict: kernel-ml-tools-libs-5.6.11-1.vsc.el7.x86_64 conflicts kernel-tools-libs < 5.6.11-1.vsc.el7
--> Restarting Dependency Resolution with new changes.
--> Running transaction check
---> Package kernel-tools-libs.x86_64 0:3.10.0-957.12.2.el7 will be updated
--> Processing Dependency: kernel-tools-libs = 3.10.0-957.12.2.el7 for package: kernel-tools-3.10.0-957.12.2.el7.x86_64
---> Package kernel-tools-libs.x86_64 0:3.10.0-1127.el7 will be an update
--> Running transaction check
---> Package kernel-tools.x86_64 0:3.10.0-957.12.2.el7 will be updated
---> Package kernel-tools.x86_64 0:3.10.0-1127.el7 will be an update
--> Processing Conflict: kernel-ml-headers-5.6.11-1.vsc.el7.x86_64 conflicts kernel-headers < 5.6.11-1.vsc.el7
No package matched to upgrade: kernel-ml-headers
--> Processing Conflict: kernel-ml-tools-libs-5.6.11-1.vsc.el7.x86_64 conflicts kernel-tools-libs < 5.6.11-1.vsc.el7
No package matched to upgrade: kernel-ml-tools-libs
--> Processing Conflict: kernel-ml-tools-5.6.11-1.vsc.el7.x86_64 conflicts kernel-tools < 5.6.11-1.vsc.el7
No package matched to upgrade: kernel-ml-tools
--> Running transaction check
---> Package kernel-ml.x86_64 0:5.6.11-1.vsc.el7 will be installed
---> Package kernel-ml-devel.x86_64 0:5.6.11-1.vsc.el7 will be installed
---> Package kernel-tools.x86_64 0:3.10.0-957.12.2.el7 will be updated
---> Package perf.x86_64 0:5.6.11-1.vsc.el7 will be installed
---> Package python-perf.x86_64 0:3.10.0-957.12.2.el7 will be updated
---> Package python-perf.x86_64 0:5.6.11-1.vsc.el7 will be an update
--> Running transaction check
---> Package kernel-ml.x86_64 0:5.6.11-1.vsc.el7 will be installed
---> Package kernel-ml-devel.x86_64 0:5.6.11-1.vsc.el7 will be installed
---> Package perf.x86_64 0:5.6.11-1.vsc.el7 will be installed
---> Package python-perf.x86_64 0:3.10.0-957.12.2.el7 will be updated
---> Package python-perf.x86_64 0:5.6.11-1.vsc.el7 will be an update
--> Finished Dependency Resolution

Packages skipped because of dependency problems:
    kernel-ml-headers-5.6.11-1.vsc.el7.x86_64 from /kernel-ml-headers-5.6.11-1.vsc.el7.x86_64
    kernel-ml-tools-5.6.11-1.vsc.el7.x86_64 from /kernel-ml-tools-5.6.11-1.vsc.el7.x86_64
    kernel-ml-tools-libs-5.6.11-1.vsc.el7.x86_64 from /kernel-ml-tools-libs-5.6.11-1.vsc.el7.x86_64
    kernel-ml-tools-libs-devel-5.6.11-1.vsc.el7.x86_64 from /kernel-ml-tools-libs-devel-5.6.11-1.vsc.el7.x86_64
    kernel-tools-3.10.0-1127.el7.x86_64 from base
    kernel-tools-libs-3.10.0-1127.el7.x86_64 from base

Dependencies Resolved

============================================================================================================================================================
 Package                               Arch              Version                       Repository                                                      Size
============================================================================================================================================================
Installing:
 kernel-ml                             x86_64            5.6.11-1.vsc.el7              /kernel-ml-5.6.11-1.vsc.el7.x86_64                             222 M
 kernel-ml-devel                       x86_64            5.6.11-1.vsc.el7              /kernel-ml-devel-5.6.11-1.vsc.el7.x86_64                        50 M
 perf                                  x86_64            5.6.11-1.vsc.el7              /perf-5.6.11-1.vsc.el7.x86_64                                  8.9 M
Updating:
 python-perf                           x86_64            5.6.11-1.vsc.el7              /python-perf-5.6.11-1.vsc.el7.x86_64                           1.6 M
Skipped (dependency problems):
 kernel-ml-headers                     x86_64            5.6.11-1.vsc.el7              /kernel-ml-headers-5.6.11-1.vsc.el7.x86_64                     4.9 M
 kernel-ml-tools                       x86_64            5.6.11-1.vsc.el7              /kernel-ml-tools-5.6.11-1.vsc.el7.x86_64                       365 k
 kernel-ml-tools-libs                  x86_64            5.6.11-1.vsc.el7              /kernel-ml-tools-libs-5.6.11-1.vsc.el7.x86_64                   71 k
 kernel-ml-tools-libs-devel            x86_64            5.6.11-1.vsc.el7              /kernel-ml-tools-libs-devel-5.6.11-1.vsc.el7.x86_64            5.9 k
 kernel-tools                          x86_64            3.10.0-1127.el7               base                                                           8.0 M
 kernel-tools-libs                     x86_64            3.10.0-1127.el7               base                                                           7.9 M

Transaction Summary
============================================================================================================================================================
Install                        3 Packages
Upgrade                        1 Package
Skipped (dependency problems)  6 Packages

Total size: 283 M
Downloading packages:
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : kernel-ml-devel-5.6.11-1.vsc.el7.x86_64                                                                                                  1/5 
  Installing : perf-5.6.11-1.vsc.el7.x86_64                                                                                                             2/5 
  Installing : kernel-ml-5.6.11-1.vsc.el7.x86_64                                                                                                        3/5 
  Updating   : python-perf-5.6.11-1.vsc.el7.x86_64                                                                                                      4/5 
  Cleanup    : python-perf-3.10.0-957.12.2.el7.x86_64                                                                                                   5/5 
  Verifying  : python-perf-5.6.11-1.vsc.el7.x86_64                                                                                                      1/5 
  Verifying  : kernel-ml-5.6.11-1.vsc.el7.x86_64                                                                                                        2/5 
  Verifying  : perf-5.6.11-1.vsc.el7.x86_64                                                                                                             3/5 
  Verifying  : kernel-ml-devel-5.6.11-1.vsc.el7.x86_64                                                                                                  4/5 
  Verifying  : python-perf-3.10.0-957.12.2.el7.x86_64                                                                                                   5/5 

Installed:
  kernel-ml.x86_64 0:5.6.11-1.vsc.el7                kernel-ml-devel.x86_64 0:5.6.11-1.vsc.el7                perf.x86_64 0:5.6.11-1.vsc.el7               

Updated:
  python-perf.x86_64 0:5.6.11-1.vsc.el7                                                                                                                     

Skipped (dependency problems):
  kernel-ml-headers.x86_64 0:5.6.11-1.vsc.el7              kernel-ml-tools.x86_64 0:5.6.11-1.vsc.el7     kernel-ml-tools-libs.x86_64 0:5.6.11-1.vsc.el7    
  kernel-ml-tools-libs-devel.x86_64 0:5.6.11-1.vsc.el7     kernel-tools.x86_64 0:3.10.0-1127.el7         kernel-tools-libs.x86_64 0:3.10.0-1127.el7        

Complete!
```
</p>
</details>

### Grub

Update grub config
```shell
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```
<details><summary>output</summary>
<p>

```log
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-5.6.11-1.vsc.el7.x86_64
Found initrd image: /boot/initramfs-5.6.11-1.vsc.el7.x86_64.img
Found linux image: /boot/vmlinuz-3.10.0-957.12.2.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-957.12.2.el7.x86_64.img
done
```
</p>
</details>

Get grub menuentries
```shell
sudo awk -F\' '/menuentry / {print $2}' /boot/grub2/grub.cfg
```
<details><summary>output</summary>
<p>

```log
CentOS Linux (5.6.11-1.vsc.el7.x86_64) 7 (Core)
CentOS Linux (3.10.0-957.12.2.el7.x86_64) 7 (Core)
```
</p>
</details>

Set default
```shell
sudo grub2-set-default 0
```

Reboot
```shell
sudo reboot
```

Check
```shell
uname -r
```
```log
5.6.11-1.vsc.el7.x86_64
```
