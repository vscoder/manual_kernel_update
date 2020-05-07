## Get kernel sources

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
