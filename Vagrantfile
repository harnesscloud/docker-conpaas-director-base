# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.network "forwarded_port", guest: 80, host: 8080

  config.vm.provider "docker" do |d|
    d.build_dir  = "."
    d.cmd        = ["/sbin/my_init", "--enable-insecure-key"]
    d.has_ssh    = true
  end

  config.ssh.username = "root"
  config.ssh.private_key_path = "phusion.key"

end
