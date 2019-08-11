Vagrant.configure("2") do |config|
    # Guest VM Name, CentOS version for base box, shared folder
    vm_name = 'default'
    vagrant_arg = ARGV[0]
    config.vm.box = "bento/centos-7.6"
    config.vm.box_version = "201907.24.0"
    config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", :mount_options => ["dmode=777","fmode=777"]

    # Guest VM settings
    config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", 3072]
        v.customize ["modifyvm", :id, "--cpus", "2"]
        v.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
        v.customize ["modifyvm", :id, "--vram", "12"]
        v.customize ["modifyvm", :id, "--ioapic", "on"]
        v.customize ["modifyvm", :id, "--audio", "none"]
        v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
        v.name = "python-vagrant-centos7"
    end

    # Set up a private IP that can be added to the host machine's hosts file
    config.vm.network "private_network", ip: "192.168.99.100"

    # Ports to forward from the guest VM to the host
    # Uncomment the line below for Apache on port 80
  	# config.vm.network "forwarded_port", guest: 80, host: 80, auto_correct: false
  	config.vm.network "forwarded_port", guest: 5432, host: 5432, auto_correct: false
  	config.vm.network "forwarded_port", guest: 8000, host: 8000, auto_correct: false
  	config.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: false
  	config.vm.network "forwarded_port", guest: 8100, host: 8100, auto_correct: false

    # Set a hostname
    if ENV['VAGRANT_HOSTNAME'].nil? and Dir.glob("#{File.dirname(__FILE__)}/.vagrant/machines/#{vm_name}/virtualbox/id").empty? and vagrant_arg == 'up'
        print "A hostname has not been provided. Please create one, or hit enter for the default.\n"
        print "Enter your hostname [vagrant.example.com]: "
        config.vm.hostname = STDIN.gets.chomp

        if config.vm.hostname == ''
            config.vm.hostname = "vagrant.example.com"
        end
    else
        config.vm.hostname = ENV['VAGRANT_HOSTNAME']
    end

    config.vm.provision "ansible_local" do |ansible|
        ansible.playbook = "provisioning/vagrant_playbook.yml"
        # ansible.verbose = "v"
    end
end

