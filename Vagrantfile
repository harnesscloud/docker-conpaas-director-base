# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.network "forwarded_port", guest: 5555, host: 5555

  config.vm.provider "docker" do |d|
    d.build_dir  = "."
    d.cmd        = ["/sbin/my_init", "--enable-insecure-key"]
    d.has_ssh    = true
  end

  config.ssh.username = "root"
  config.ssh.private_key_path = "keys/phusion.key"

end
