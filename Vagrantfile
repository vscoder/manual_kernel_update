# Describe VMs
MACHINES = {
  # VM name "kernel update"
  :"kernel-update" => {
              # VM box
              :box_name => "centos/7",
              # VM CPU count
              :cpus => 8,
              # VM RAM size (Mb)
              :memory => 8196,
              # networks
              :net => [],
              # forwarded ports
              :forwarded_port => [],
              # provision scripts
              :provision_scripts => [
                {
                  :path => "./packer/scripts/stage-1-kernel-compile.sh",
                  :reload => true
                },
                {
                  :path => "./packer/scripts/stage-1-install-guest-additions.sh",
                  :reload => true
                }
              ],
            }
}

# Function to check whether VM was already provisioned
def provisioned?(vm_name='default', provider='virtualbox')
  File.exist?(".vagrant/machines/#{vm_name}/#{provider}/action_provision")
end

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    # Disable shared folders if not provisioned
    config.vm.synced_folder ".", "/vagrant", type: "virtualbox", disabled: not(provisioned?(boxname))
    # Apply VM config
    config.vm.define boxname do |box|
      # Set VM base box and hostname
      box.vm.box = boxconfig[:box_name]
      box.vm.host_name = boxname.to_s
      # Additional network config if present
      if boxconfig.key?(:net)
        boxconfig[:net].each do |ipconf|
          box.vm.network "private_network", ipconf
        end
      end
      # Port-forward config if present
      if boxconfig.key?(:forwarded_port)
        boxconfig[:forwarded_port].each do |port|
          box.vm.network "forwarded_port", port
        end
      end
      # VM resources config
      box.vm.provider "virtualbox" do |v|
        # Set VM RAM size and CPU count
        v.memory = boxconfig[:memory]
        v.cpus = boxconfig[:cpus]
      end
      # provision scripts
      if boxconfig.key?(:provision_scripts)
        boxconfig[:provision_scripts].each do |script|
          box.vm.provision "shell",
              # Path to script
              path: script[:path],
              # Set environment variables for script
              env: {"PROVISIONER" => "vagrant"}
          # reload VM
          config.vagrant.plugins = ["vagrant-reload"]
          box.vm.provision :reload if script[:reload]
        end
      end
    end
  end
end
