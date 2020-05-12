# Vagrant provision

It's need to build a custom kernel with `vagrant up`.

## Solution

- Create backup of `Vagrantfile` named `Vagrantfile-custom`
- Update provision scripts. Don't reboot VM at end of each script. Use `vagrant-reload` plugin for it.
- Add to `Vagrantfile` provision of VM with scripts
  - `packer/scripts/stage-1-kernel-compile.sh`
  - `packer/scripts/stage-1-install-guest-additions.sh`

## Problems

### Reboot VM

Before an installation of the VBoxGuestAdditions, the VM must be rebooted with an updated kernel. But with command `shutdown -r now` is executed, vagrant terminates with an error. To fix this behavior, there is added environment variable `PROVISIONER`. If `PROVISIONER` value is `vagrant` then `shutdown -r now` isn't executed.

For VM reboot, there is plugin `vagrant-reload` used.

### Enable shared folder

There isn't VBoxGuestAdditions installed before provisioning box when `vagrant up` process is started. But it's already installed after provision is finished. There is added function `provisioned?` which checks provision is finished. But the function `provisioned?` return `true` only when a provision process is finished. Because of `reload` is a part of a provision process, the function `provisioned?` returns `false` on a last `box.vm.provision :reload` action.

So, it's need to do `vagrant reload` by hand.

### Fix packer build

Possible error with uninitialized variable `PROVISIONER` when `packer build centos-custom.json` is fixed by manipulation with `set -u`/`set +u` flag.
