# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# # Provisioning script
$script = <<SCRIPT
  sudo apt-get update -qq

  sudo apt-get install -y podman build-essential
SCRIPT

Vagrant.configure('2') do |config|
  config.vm.box      = 'ubuntu/hirsute64'
  config.vm.hostname = 'mememaker'
  config.vm.network :forwarded_port, guest: 9393, host: 9393
  config.vm.provision "shell", inline: $script, privileged: false

  config.vm.provider 'virtualbox' do |v|
    v.memory = 1024
    v.cpus = 1

    # Set the timesync threshold to 5 seconds, instead of the default 20 minutes.
    v.customize ['guestproperty', 'set', :id, '/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold', 5000]
  end
end
