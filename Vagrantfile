Vagrant.configure("2") do |config|

  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.provider "docker" do |d|
    d.build_dir = "."
    d.cmd       = ["/sbin/my_init", "--enable-insecure-key"]
    d.has_ssh   = true
  end

  config.ssh.username = "root"
  config.ssh.private_key_path = "keys/phusion.key"

end
