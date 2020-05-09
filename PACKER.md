# Packer

Now we build vagrant box with custom kernel using packer.

## Cinfiguration

First, create stage1 script: [packer/scripts/stage-1-kernel-compile.sh](packer/scripts/stage-1-kernel-compile.sh) to automate kernel compilation and installation process

Then, create [packer/scripts/stage-1-install-guest-additions.sh](packer/scripts/stage-1-install-guest-additions.sh) script, to install VirtualBox Guest Additions. It makes usable a shared folders.

After that, copy `packer/centos.json` to `packer/centos-custom.json` and add resources required for compiling kernel from sources. Updated:
- ```json
  "artifact_description": "CentOS 7.7 with custom kernel 5x"`
  ```
- ```json
  "disk_size": "30000"
  ```
- ```json
  [ "modifyvm", "{{.Name}}", "--memory", "8196" ]
  ```
- ```json
  [ "modifyvm", "{{.Name}}", "--cpus", "8" ]
  ```
- ```json
  "output": "centos-{{user `artifact_version`}}-kernel-5-x86_64-Minimal-custom.box"
  ```
- ```json
  "scripts": [
              "scripts/stage-1-kernel-compile.sh",
              "scripts/stage-1-install-guest-additions.sh",
              "scripts/stage-2-clean.sh"
            ]
  ```

So, we have [packer/centos-custom.json](packer/centos-custom.json) packer image configuration, and 3 provisioning scripts:
- [packer/scripts/stage-1-kernel-compile.sh](packer/scripts/stage-1-kernel-compile.sh)
- [packer/scripts/stage-1-install-guest-additions.sh](packer/scripts/stage-1-install-guest-additions.sh)
- [packer/scripts/stage-2-clean.sh](packer/scripts/stage-2-clean.sh)

## Build

Build vagrant box via packer
```shell
packer build centos-custom.json 2>&1 | tee ../assets/packer-build-custom.log
```
[output](assets/packer-build-custom.log)

Check box size
```shell
ls -lah centos-7.7.1908-kernel-5-x86_64-Minimal-custom.box 
```
```log
-rw-rw-r-- 1 vscoder vscoder 1,2G мая  9 17:22 centos-7.7.1908-kernel-5-x86_64-Minimal-custom.box
```

**1.2Gb** - not so bad))


## Test

Import image
```shell
vagrant box add --name centos-7-5-custom centos-7.7.1908-kernel-5-x86_64-Minimal-custom.box 
```
```log
==> box: Box file was not detected as metadata. Adding it directly...
==> box: Adding box 'centos-7-5-custom' (v0) for provider: 
    box: Unpacking necessary files from: file:///home/vscoder/projects/otus/linux-2020-04/manual_kernel_update/packer/centos-7.7.1908-kernel-5-x86_64-Minimal-custom.box
==> box: Successfully added box 'centos-7-5-custom' (v0) for 'virtualbox'!
```

Run and check kernel version and shared folder

Prepare [test/Vagrantfile](test/Vagrantfile)
```ruby
:box_name => "centos-7-5-custom",
```

On host: Up
```shell
cd test/
vagrant up
vagrant ssh
```
<details><summary>output</summary>
<p>

```log
Bringing machine 'kernel-update' up with 'virtualbox' provider...
==> kernel-update: Importing base box 'centos-7-5-custom'...
==> kernel-update: Matching MAC address for NAT networking...
==> kernel-update: Setting the name of the VM: test_kernel-update_1589034550385_99737
==> kernel-update: Fixed port collision for 22 => 2222. Now on port 2200.
==> kernel-update: Clearing any previously set network interfaces...
==> kernel-update: Preparing network interfaces based on configuration...
    kernel-update: Adapter 1: nat
==> kernel-update: Forwarding ports...
    kernel-update: 22 (guest) => 2200 (host) (adapter 1)
==> kernel-update: Running 'pre-boot' VM customizations...
==> kernel-update: Booting VM...
==> kernel-update: Waiting for machine to boot. This may take a few minutes...
    kernel-update: SSH address: 127.0.0.1:2200
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
==> kernel-update: Setting hostname...
==> kernel-update: Mounting shared folders...
    kernel-update: /vagrant => /home/vscoder/projects/otus/linux-2020-04/manual_kernel_update/test
Last login: Sat May  9 14:19:56 2020 from 10.0.2.2
```
</p>
</details>

On instance:

Check kernel version
```shell
uname -r
```
```log
5.6.11-1.vsc.el7.x86_64
```

Check `vboxsf` kernel module loaded
```shell
lsmod | grep vboxsf
```
```log
vboxsf                 81920  1 
vboxguest             360448  2 vboxsf
```

Check `/vagrant` folder content
```shell
ls -la /vagrant
```
```log
итого 12
drwxrwxr-x   1 vagrant vagrant 4096 май  8 21:22 .
dr-xr-xr-x. 18 root    root     259 май  9 13:27 ..
drwxrwxr-x   1 vagrant vagrant 4096 апр 30 23:16 .vagrant
-rw-rw-r--   1 vagrant vagrant 1365 май  9 13:22 Vagrantfile
```

Cleanup (on host)
```shell
vagrant destroy
vagrant box remove centos-7-5-custom
```

## Upload box to vagrant cloud

From `packer/` directory
```shell
cd packer/
```

Login to vagrant cloud
```shell
vagrant cloud auth login
```
<details><summary>output</summary>
<p>

```log
In a moment we will ask for your username and password to HashiCorp's
Vagrant Cloud. After authenticating, we will store an access token locally on
disk. Your login details will be transmitted over a secure connection, and
are never stored on disk locally.

If you do not have an Vagrant Cloud account, sign up at
https://www.vagrantcloud.com

Vagrant Cloud username or email: vscoder
Password (will be hidden): 
Token description (Defaults to "Vagrant login from vsc-home"): 
You are now logged in.
```
</p>
</details>

Publish box
```shell
vagrant cloud publish --release vscoder/centos-7-5-custom 1.0 virtualbox centos-7.7.1908-kernel-5-x86_64-Minimal-custom.box
```
<details><summary>output</summary>
<p>

```log
You are about to publish a box on Vagrant Cloud with the following options:
vscoder/centos-7-5-custom:   (v1.0) for provider 'virtualbox'
Automatic Release:     true
Do you wish to continue? [y/N] y
==> cloud: Creating a box entry...
==> cloud: Creating a version entry...
==> cloud: Creating a provider entry...
==> cloud: Uploading provider with file /home/vscoder/projects/otus/linux-2020-04/manual_kernel_update/packer/centos-7.7.1908-kernel-5-x86_64-Minimal-custom.box
==> cloud: Releasing box...
Complete! Published vscoder/centos-7-5-custom
tag:             vscoder/centos-7-5-custom
username:        vscoder
name:            centos-7-5-custom
private:         false
downloads:       0
created_at:      2020-05-09T14:48:59.478Z
updated_at:      2020-05-09T15:41:36.642Z
current_version: 1.0
providers:       virtualbox
old_versions:    ...
```
</p>
</details>

And finally, use published image at main [test/Vagrantfile](test/Vagrantfile)

Replace image name to:
```ruby
:box_name => "vscoder/centos-7-5-custom",
```
