Vagrant.configure("2") do |config|

  config.vm.define "phusion" do |v|
    v.vm.provider "docker" do |d|
      d.image   = "phusion/baseimage"
      d.cmd     = ["/sbin/my_init", "--enable-insecure-key"]
      d.has_ssh = true
    end
 
    v.ssh.username = "root"
    v.ssh.private_key_path = "phusion.key"
  
  end
end
