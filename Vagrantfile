Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/xenial64"
    config.vm.provision "shell", privileged: false, inline: <<-SHELL
        sudo apt-get update
        sudo apt-get install g++
        sudo apt-get install -y git
        config.vm.provision:shell,path:'install-pyenv.sh',privileged:true
        config.vm.provision:shell,path:'python/install-python.sh',args:'pyenv 2.7.15',privileged:true
        config.vm.provision:shell,path:'python/install-python.sh',args:'pyenv 3.6.5',privileged:true
    SHELL
end