Vagrant.configure("2") do |config|

  config.vm.define "phusion" do |v|
    v.vm.network "forwarded_port", guest: 80, host: 8080
    v.vm.provider "docker" do |d|
      d.build_dir = "."
      d.cmd       = ["/sbin/my_init", "--enable-insecure-key"]
      d.has_ssh   = true
    end
 
    v.ssh.username = "root"
    v.ssh.private_key_path = "keys/phusion.key"
  
  end
end
