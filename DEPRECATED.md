# VirtualBox shared folder configuration

> Here is described VBoxGuestAdditions installation process via vagrant plugin named `vbguest`, but with ELRepo's `kernel-ml` installed.

Vagrant documentation: https://www.vagrantup.com/docs/synced-folders/virtualbox.html

Try to mount shared folder into VM

Create mountpoint
```shell
sudo mkdir /vagrant
```

Try to mount
```shell
sudo mount -t vboxsf -o uid=1000,gid=1000 vagrant /vagrant
```
```log
mount: unknown filesystem type 'vboxsf'
```

And StackOverflow helps us=)

https://stackoverflow.com/questions/43492322/vagrant-was-unable-to-mount-virtualbox-shared-folders

Let's do it!

```shell
ls -lh /sbin/mount.vboxsf
```
```log
ls: cannot access /sbin/mount.vboxsf: No such file or directory
```

If the link `/sbin/mount.vboxsf` does not exists in the first place, than the VBoxGuestAdditions couldn't be installed.

## Install vagrant vbguest plugin

```shell
vagrant plugin install vagrant-vbguest
```
```log
Installing the 'vagrant-vbguest' plugin. This can take a few minutes...
Fetching: micromachine-3.0.0.gem (100%)
Fetching: vagrant-vbguest-0.24.0.gem (100%)
Installed the plugin 'vagrant-vbguest (0.24.0)'!
```

## Install VirtualBox Guest Additions

```shell
vagrant vbguest --do install --no-cleanup
```
<details><summary>output</summary>
<p>

```log
[kernel-update] No Virtualbox Guest Additions installation found.
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.yandex.ru
 * elrepo: mirrors.colocall.net
 * epel: fedora-mirror02.rbc.ru
 * extras: mirror.corbina.net
 * updates: centos-mirror.rbc.ru
Resolving Dependencies
--> Running transaction check
---> Package centos-release.x86_64 0:7-6.1810.2.el7.centos will be updated
---> Package centos-release.x86_64 0:7-8.2003.0.el7.centos will be an update
--> Finished Dependency Resolution

Dependencies Resolved

================================================================================
 Package              Arch         Version                     Repository  Size
================================================================================
Updating:
 centos-release       x86_64       7-8.2003.0.el7.centos       base        26 k

Transaction Summary
================================================================================
Upgrade  1 Package

Total download size: 26 k
Downloading packages:
No Presto metadata available for base
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Updating   : centos-release-7-8.2003.0.el7.centos.x86_64                  1/2 
  Cleanup    : centos-release-7-6.1810.2.el7.centos.x86_64                  2/2 
  Verifying  : centos-release-7-8.2003.0.el7.centos.x86_64                  1/2 
  Verifying  : centos-release-7-6.1810.2.el7.centos.x86_64                  2/2 

Updated:
  centos-release.x86_64 0:7-8.2003.0.el7.centos                                 

Complete!
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.yandex.ru
 * elrepo: mirrors.colocall.net
 * epel: fedora-mirror02.rbc.ru
 * extras: mirror.corbina.net
 * updates: centos-mirror.rbc.ru
No package kernel-devel-5.6.8-1.el7.elrepo.x86_64 available.
Error: Nothing to do
The following SSH command responded with a non-zero exit status.
Vagrant assumes that this means the command failed!

yum install -y kernel-devel-`uname -r` --enablerepo=C*-base --enablerepo=C*-updates

Stdout from the command:

Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.yandex.ru
 * elrepo: mirrors.colocall.net
 * epel: fedora-mirror02.rbc.ru
 * extras: mirror.corbina.net
 * updates: centos-mirror.rbc.ru
No package kernel-devel-5.6.8-1.el7.elrepo.x86_64 available.


Stderr from the command:

Error: Nothing to do
```
</p>
</details>

As we can see, `vbguest` plugin tries to install wrong kernel package: `kernel-devel-` except `kernel-ml-devel-`

There are many ways to solve this issue:

#
## Fix package name in vbguest gem sources

NOTE: This is the wrong way, because is's vwry difficult for automatization (we need to change file on host system)

Edit file `~/.vagrant.d/gems/2.4.9/gems/vagrant-vbguest-0.24.0/lib/vagrant-vbguest/installers/centos.rb`

Line 72:
```ruby
      def install_kernel_devel(opts=nil, &block)
        rel = has_rel_repo? ? release_version : '*'
        cmd = "yum install -y kernel-devel-`uname -r` --enablerepo=C#{rel}-base --enablerepo=C#{rel}-updates"
        communicate.sudo(cmd, opts, &block)
      end
```
replace to
```ruby
      def install_kernel_devel(opts=nil, &block)
        rel = has_rel_repo? ? release_version : '*'
        cmd = "yum install -y kernel-ml-devel-`uname -r` --enablerepo=C#{rel}-base --enablerepo=C#{rel}-updates --enablerepo elrepo-kernel"
        communicate.sudo(cmd, opts, &block)
      end
```

And then run installation again:

```shell
vagrant vbguest --do install --no-cleanup               
```
<details><summary>output</summary>
<p>

```log
[kernel-update] No Virtualbox Guest Additions installation found.
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.yandex.ru
 * elrepo: mirrors.colocall.net
 * epel: fedora-mirror02.rbc.ru
 * extras: mirror.corbina.net
 * updates: centos-mirror.rbc.ru
Package centos-release-7-8.2003.0.el7.centos.x86_64 already installed and latest version
Nothing to do
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.yandex.ru
 * elrepo: mirrors.colocall.net
 * elrepo-kernel: mirrors.colocall.net
 * epel: fedora-mirror02.rbc.ru
 * extras: mirror.corbina.net
 * updates: centos-mirror.rbc.ru
Package kernel-ml-devel-5.6.8-1.el7.elrepo.x86_64 already installed and latest version
Nothing to do
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.yandex.ru
 * elrepo: mirrors.colocall.net
 * epel: fedora-mirror02.rbc.ru
 * extras: mirror.corbina.net
 * updates: centos-mirror.rbc.ru
Package 4:perl-5.16.3-295.el7.x86_64 already installed and latest version
Package bzip2-1.0.6-13.el7.x86_64 already installed and latest version
Resolving Dependencies
--> Running transaction check
---> Package binutils.x86_64 0:2.27-34.base.el7 will be updated
---> Package binutils.x86_64 0:2.27-43.base.el7 will be an update
---> Package elfutils-libelf-devel.x86_64 0:0.176-4.el7 will be installed
--> Processing Dependency: elfutils-libelf(x86-64) = 0.176-4.el7 for package: elfutils-libelf-devel-0.176-4.el7.x86_64
--> Processing Dependency: pkgconfig(zlib) for package: elfutils-libelf-devel-0.176-4.el7.x86_64
---> Package gcc.x86_64 0:4.8.5-39.el7 will be installed
--> Processing Dependency: libgomp = 4.8.5-39.el7 for package: gcc-4.8.5-39.el7.x86_64
--> Processing Dependency: cpp = 4.8.5-39.el7 for package: gcc-4.8.5-39.el7.x86_64
--> Processing Dependency: libgcc >= 4.8.5-39.el7 for package: gcc-4.8.5-39.el7.x86_64
--> Processing Dependency: glibc-devel >= 2.2.90-12 for package: gcc-4.8.5-39.el7.x86_64
--> Processing Dependency: libmpfr.so.4()(64bit) for package: gcc-4.8.5-39.el7.x86_64
--> Processing Dependency: libmpc.so.3()(64bit) for package: gcc-4.8.5-39.el7.x86_64
---> Package make.x86_64 1:3.82-23.el7 will be updated
---> Package make.x86_64 1:3.82-24.el7 will be an update
--> Running transaction check
---> Package cpp.x86_64 0:4.8.5-39.el7 will be installed
---> Package elfutils-libelf.x86_64 0:0.172-2.el7 will be updated
--> Processing Dependency: elfutils-libelf(x86-64) = 0.172-2.el7 for package: elfutils-libs-0.172-2.el7.x86_64
---> Package elfutils-libelf.x86_64 0:0.176-4.el7 will be an update
---> Package glibc-devel.x86_64 0:2.17-307.el7.1 will be installed
--> Processing Dependency: glibc-headers = 2.17-307.el7.1 for package: glibc-devel-2.17-307.el7.1.x86_64
--> Processing Dependency: glibc = 2.17-307.el7.1 for package: glibc-devel-2.17-307.el7.1.x86_64
--> Processing Dependency: glibc-headers for package: glibc-devel-2.17-307.el7.1.x86_64
---> Package libgcc.x86_64 0:4.8.5-36.el7_6.2 will be updated
---> Package libgcc.x86_64 0:4.8.5-39.el7 will be an update
---> Package libgomp.x86_64 0:4.8.5-36.el7_6.2 will be updated
---> Package libgomp.x86_64 0:4.8.5-39.el7 will be an update
---> Package libmpc.x86_64 0:1.0.1-3.el7 will be installed
---> Package mpfr.x86_64 0:3.1.1-4.el7 will be installed
---> Package zlib-devel.x86_64 0:1.2.7-18.el7 will be installed
--> Running transaction check
---> Package elfutils-libs.x86_64 0:0.172-2.el7 will be updated
---> Package elfutils-libs.x86_64 0:0.176-4.el7 will be an update
---> Package glibc.x86_64 0:2.17-260.el7_6.5 will be updated
--> Processing Dependency: glibc = 2.17-260.el7_6.5 for package: glibc-common-2.17-260.el7_6.5.x86_64
---> Package glibc.x86_64 0:2.17-307.el7.1 will be an update
---> Package glibc-headers.x86_64 0:2.17-307.el7.1 will be installed
--> Processing Dependency: kernel-headers >= 2.2.1 for package: glibc-headers-2.17-307.el7.1.x86_64
--> Processing Dependency: kernel-headers for package: glibc-headers-2.17-307.el7.1.x86_64
--> Running transaction check
---> Package glibc-common.x86_64 0:2.17-260.el7_6.5 will be updated
---> Package glibc-common.x86_64 0:2.17-307.el7.1 will be an update
---> Package kernel-headers.x86_64 0:3.10.0-1127.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

================================================================================
 Package                    Arch        Version                 Repository
                                                                           Size
================================================================================
Installing:
 elfutils-libelf-devel      x86_64      0.176-4.el7             base       40 k
 gcc                        x86_64      4.8.5-39.el7            base       16 M
Updating:
 binutils                   x86_64      2.27-43.base.el7        base      5.9 M
 make                       x86_64      1:3.82-24.el7           base      421 k
Installing for dependencies:
 cpp                        x86_64      4.8.5-39.el7            base      5.9 M
 glibc-devel                x86_64      2.17-307.el7.1          base      1.1 M
 glibc-headers              x86_64      2.17-307.el7.1          base      689 k
 kernel-headers             x86_64      3.10.0-1127.el7         base      8.9 M
 libmpc                     x86_64      1.0.1-3.el7             base       51 k
 mpfr                       x86_64      3.1.1-4.el7             base      203 k
 zlib-devel                 x86_64      1.2.7-18.el7            base       50 k
Updating for dependencies:
 elfutils-libelf            x86_64      0.176-4.el7             base      195 k
 elfutils-libs              x86_64      0.176-4.el7             base      291 k
 glibc                      x86_64      2.17-307.el7.1          base      3.6 M
 glibc-common               x86_64      2.17-307.el7.1          base       11 M
 libgcc                     x86_64      4.8.5-39.el7            base      102 k
 libgomp                    x86_64      4.8.5-39.el7            base      158 k

Transaction Summary
================================================================================
Install  2 Packages (+7 Dependent packages)
Upgrade  2 Packages (+6 Dependent packages)

Total download size: 55 M
Downloading packages:
No Presto metadata available for base
--------------------------------------------------------------------------------
Total                                               11 MB/s |  55 MB  00:05     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Updating   : libgcc-4.8.5-39.el7.x86_64                                  1/25 
  Updating   : glibc-2.17-307.el7.1.x86_64                                 2/25 
warning: /etc/nsswitch.conf created as /etc/nsswitch.conf.rpmnew
  Updating   : glibc-common-2.17-307.el7.1.x86_64                          3/25 
  Installing : mpfr-3.1.1-4.el7.x86_64                                     4/25 
  Installing : libmpc-1.0.1-3.el7.x86_64                                   5/25 
  Updating   : elfutils-libelf-0.176-4.el7.x86_64                          6/25 
  Installing : cpp-4.8.5-39.el7.x86_64                                     7/25 
  Updating   : libgomp-4.8.5-39.el7.x86_64                                 8/25 
  Updating   : binutils-2.27-43.base.el7.x86_64                            9/25 
  Installing : kernel-headers-3.10.0-1127.el7.x86_64                      10/25 
  Installing : glibc-headers-2.17-307.el7.1.x86_64                        11/25 
  Installing : glibc-devel-2.17-307.el7.1.x86_64                          12/25 
  Installing : zlib-devel-1.2.7-18.el7.x86_64                             13/25 
  Installing : elfutils-libelf-devel-0.176-4.el7.x86_64                   14/25 
  Installing : gcc-4.8.5-39.el7.x86_64                                    15/25 
  Updating   : elfutils-libs-0.176-4.el7.x86_64                           16/25 
  Updating   : 1:make-3.82-24.el7.x86_64                                  17/25 
  Cleanup    : elfutils-libs-0.172-2.el7.x86_64                           18/25 
  Cleanup    : elfutils-libelf-0.172-2.el7.x86_64                         19/25 
  Cleanup    : binutils-2.27-34.base.el7.x86_64                           20/25 
  Cleanup    : 1:make-3.82-23.el7.x86_64                                  21/25 
  Cleanup    : libgomp-4.8.5-36.el7_6.2.x86_64                            22/25 
  Cleanup    : glibc-2.17-260.el7_6.5.x86_64                              23/25 
  Cleanup    : glibc-common-2.17-260.el7_6.5.x86_64                       24/25 
  Cleanup    : libgcc-4.8.5-36.el7_6.2.x86_64                             25/25 
  Verifying  : gcc-4.8.5-39.el7.x86_64                                     1/25 
  Verifying  : zlib-devel-1.2.7-18.el7.x86_64                              2/25 
  Verifying  : glibc-common-2.17-307.el7.1.x86_64                          3/25 
  Verifying  : libgomp-4.8.5-39.el7.x86_64                                 4/25 
  Verifying  : 1:make-3.82-24.el7.x86_64                                   5/25 
  Verifying  : kernel-headers-3.10.0-1127.el7.x86_64                       6/25 
  Verifying  : glibc-2.17-307.el7.1.x86_64                                 7/25 
  Verifying  : elfutils-libelf-0.176-4.el7.x86_64                          8/25 
  Verifying  : libmpc-1.0.1-3.el7.x86_64                                   9/25 
  Verifying  : elfutils-libs-0.176-4.el7.x86_64                           10/25 
  Verifying  : glibc-headers-2.17-307.el7.1.x86_64                        11/25 
  Verifying  : binutils-2.27-43.base.el7.x86_64                           12/25 
  Verifying  : elfutils-libelf-devel-0.176-4.el7.x86_64                   13/25 
  Verifying  : mpfr-3.1.1-4.el7.x86_64                                    14/25 
  Verifying  : cpp-4.8.5-39.el7.x86_64                                    15/25 
  Verifying  : glibc-devel-2.17-307.el7.1.x86_64                          16/25 
  Verifying  : libgcc-4.8.5-39.el7.x86_64                                 17/25 
  Verifying  : binutils-2.27-34.base.el7.x86_64                           18/25 
  Verifying  : libgcc-4.8.5-36.el7_6.2.x86_64                             19/25 
  Verifying  : glibc-common-2.17-260.el7_6.5.x86_64                       20/25 
  Verifying  : glibc-2.17-260.el7_6.5.x86_64                              21/25 
  Verifying  : libgomp-4.8.5-36.el7_6.2.x86_64                            22/25 
  Verifying  : elfutils-libelf-0.172-2.el7.x86_64                         23/25 
  Verifying  : 1:make-3.82-23.el7.x86_64                                  24/25 
  Verifying  : elfutils-libs-0.172-2.el7.x86_64                           25/25 

Installed:
  elfutils-libelf-devel.x86_64 0:0.176-4.el7      gcc.x86_64 0:4.8.5-39.el7     

Dependency Installed:
  cpp.x86_64 0:4.8.5-39.el7             glibc-devel.x86_64 0:2.17-307.el7.1    
  glibc-headers.x86_64 0:2.17-307.el7.1 kernel-headers.x86_64 0:3.10.0-1127.el7
  libmpc.x86_64 0:1.0.1-3.el7           mpfr.x86_64 0:3.1.1-4.el7              
  zlib-devel.x86_64 0:1.2.7-18.el7     

Updated:
  binutils.x86_64 0:2.27-43.base.el7          make.x86_64 1:3.82-24.el7         

Dependency Updated:
  elfutils-libelf.x86_64 0:0.176-4.el7   elfutils-libs.x86_64 0:0.176-4.el7    
  glibc.x86_64 0:2.17-307.el7.1          glibc-common.x86_64 0:2.17-307.el7.1  
  libgcc.x86_64 0:4.8.5-39.el7           libgomp.x86_64 0:4.8.5-39.el7         

Complete!
Copy iso file /usr/share/virtualbox/VBoxGuestAdditions.iso into the box /tmp/VBoxGuestAdditions.iso
Mounting Virtualbox Guest Additions ISO to: /mnt
mount: /dev/loop0 is write-protected, mounting read-only
Forcing installation of Virtualbox Guest Additions 6.0.20 - guest version is unknown
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
5.6.8-1.el7.elrepo.x86_64.
Redirecting to /bin/systemctl start vboxadd.service
Redirecting to /bin/systemctl start vboxadd-service.service
```
</p>
</details>

And check result
```shell
sudo mount -t vboxsf -o uid=1000,gid=1000 vagrant /vagrant
```
```log
/sbin/mount.vboxsf: shared folder 'vagrant' was not found (check VM settings / spelling)
```

Enable shared folder in [Vagrantfile](Vagrantfile): line 21
```ruby
    config.vm.synced_folder ".", "/vagrant", type: "virtualbox", disabled: false
```
and reload VM
```shell
vagrant reload
```
<details><summary>output</summary>
<p>

```log
==> kernel-update: Attempting graceful shutdown of VM...
==> kernel-update: Checking if box 'centos/7' version '1905.1' is up to date...
==> kernel-update: Clearing any previously set forwarded ports...
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
==> kernel-update: Machine booted and ready!
[kernel-update] GuestAdditions 6.0.20 running --- OK.
==> kernel-update: Checking for guest additions in VM...
==> kernel-update: Setting hostname...
==> kernel-update: Mounting shared folders...
    kernel-update: /vagrant => /home/vscoder/projects/otus/linux-2020-04/manual_kernel_update
==> kernel-update: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> kernel-update: flag to force provisioning. Provisioners marked to run always will still run.
```
</p>
</details>

```shell
vagrant ssh
Last login: Wed Apr 29 22:46:47 2020 from 10.0.2.2
[vagrant@kernel-update ~]$
```
```shell
sudo mount -t vboxsf -o uid=1000,gid=1000 vagrant /vagrant
```
SUCCESS!
```shell
ls -la /vagrant
```
```log
total 68
drwxrwxr-x.  1 vagrant vagrant  4096 апр 29 21:29 .
dr-xr-xr-x. 18 root    root      255 апр 29 21:51 ..
-rw-rw-r--.  1 vagrant vagrant 35052 апр 29 22:52 BASE.md
drwxrwxr-x.  1 vagrant vagrant  4096 апр 29 22:50 .git
-rw-rw-r--.  1 vagrant vagrant     9 апр 29 21:29 .gitignore
drwxrwxr-x.  1 vagrant vagrant  4096 апр 29 19:39 manual
drwxrwxr-x.  1 vagrant vagrant  4096 апр 29 19:39 packer
-rw-rw-r--.  1 vagrant vagrant    64 апр 29 21:24 README.md
drwxrwxr-x.  1 vagrant vagrant  4096 апр 29 19:51 .vagrant
-rw-rw-r--.  1 vagrant vagrant  1356 апр 29 22:46 Vagrantfile
```


# Get kernel sources

Documentation: https://wiki.centos.org/HowTos/I_need_the_Kernel_Source

But, you probably want a fresh mainline kernel from ELRepo! So, first, install ELRepo and kernel-ml sources.

```shell
sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
sudo yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
```
<details><summary>output</summary>
<p>

```log
Failed to set locale, defaulting to C
Loaded plugins: fastestmirror
elrepo-release-7.el7.elrepo.noarch.rpm                                                                                               | 8.5 kB  00:00:00     
Examining /var/tmp/yum-root-rRfsht/elrepo-release-7.el7.elrepo.noarch.rpm: elrepo-release-7.0-4.el7.elrepo.noarch
Marking /var/tmp/yum-root-rRfsht/elrepo-release-7.el7.elrepo.noarch.rpm to be installed
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

Oops... There isn't kernel sources. Won't complete this way now. To [deprecated](DEPRECATED.md)!

Mb f*#k it? Oh no... F*#k a sleeping! 8)
