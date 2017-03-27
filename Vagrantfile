# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
    config.vm.box = "bento/centos-7.2"
    config.vm.box_url = "https://atlas.hashicorp.com/bento/boxes/centos-7.2/versions/2.2.3/providers/virtualbox.box"
    config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", :mount_options => ["dmode=777","fmode=777"]

    config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", "1536"]
        v.customize ["modifyvm", :id, "--cpus", "2"]
        v.customize ["modifyvm", :id, "--cpuexecutioncap", "75"]
        v.customize ["modifyvm", :id, "--vram", "12"]
        v.customize ["modifyvm", :id, "--ioapic", "on"]
    end

    config.vm.network "private_network", ip: "192.168.99.100"
    config.vm.network "forwarded_port", guest: 80, host: 80, auto_correct: false
    config.vm.network "forwarded_port", guest: 5432, host: 5432, auto_correct: true
    config.vm.network "forwarded_port", guest: 8000, host: 8000, auto_correct: true
    config.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: true
    config.vm.network "forwarded_port", guest: 8100, host: 8100, auto_correct: true
    config.vm.hostname = "vagrant.example.com"

    # config.vm.provision "shell", path: "bootstrap.sh"
    config.vm.provision "ansible" do |ansible|
        ansible.verbose = "v"
        ansible.playbook = "playbook.yml"
    end
end

