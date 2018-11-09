# Development Environment
I format/break/destroy my machines quite regularly. It is rather tedious to continually have to install the same software all the time and one of my regular work disruptions is forgetting to install a specific software. So I am attempting to aggregate all the possible build artefacts I need into this page; in order to streamline installation across multiple machines and environments.

This is an exploratory piece, and I will be adding to it over the next few weeks. If you have any advice, please raise an issue, submit a pull request or email me. 
## Methods
There are a few ways to automate development environment setups. I am interested in creating a *one size fits all* service that will look at the currently running OS, the machine specifications, a few other things, and then install the packages the user wants with (hopefully) no supervision.
### Vagrant
I previously used vagrant with a simple Vagrantfile that provisioned my box with the correct applications. 
If you don't know what Vagrant is; the [documentation](https://www.vagrantup.com/intro/index.html) lists it as follows:
> Vagrant is a tool for building and managing virtual machine environments in a single workflow. With an easy-to-use workflow and focus on automation, Vagrant lowers development environment setup time, increases production parity, and makes the "works on my machine" excuse a relic of the past.

The main issue with this for me is the fact that it is headless. Also, if I am running an Ubuntu installation - it doesn't make much sense to run Vagrant when I could just install the packages I need onto the machine itself. (Unless the work I am doing depends on something like python2.7, or anything that has very specific dependencies which could make other development a nightmare)

However, I do think that it might be useful to take a look at the Vagrantfile I was using in order to see how I could improve it, and then possibly look at other tools that could automate the setup alongside it.
```Vagrantfile
Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/xenial64"
    config.vm.network "private_network", ip: "192.168.33.10"
    config.vm.synced_folder "../../Code", "/opt/vagrant_data"

    config.vm.provision "shell", inline: <<-SHELL
        apt-get update
        apt-get install -y git
        apt-get install python-dev python-pip -q -y
        sudo add-apt-repository -y ppa:webupd8team/java
        sudo apt-get update
        echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
        sudo apt-get -y install oracle-java8-installer
        sudo apt-get install libboost-all-dev
        sudo apt-get install g++
        sudo apt-get install build-essential
        sudo apt-get update
        sudo apt-get upgrade
    SHELL
end
```
So this is my Vagrantfile. 

A brief description of what is happening above. This Vagrantfile is simply run by calling `vagrant up`, vagrant handles everything from there. It creates a xenial based ubuntu virtualbox, configures it to output to the ip and adds a synced folder that will allow the code in my `Code` folder to be available to the virtual machine. It then *provisions* the machine with git, python, java, boost and g++. These are all the tools I needed in my first semester courses.

There are a few problems with this Vagrantfile that I would like to fix. Firstly, the xenial64 box is running 16.04 - and while that distribution is fine I would like to use 18.04 in the future. However, at the time of writing it seems there aren't any major 18.04 boxes available at the vagrant box website [here](https://app.vagrantup.com/boxes/search).  So I will have to change that at another stage. 

Then I install `python-dev`, but the issue with that is that it will make my installation dependent on a specific python version. However, the work I am doing currently requires that I have python 2.7 as the default.  So I want to use a tool like [pyenv](https://github.com/pyenv/pyenv) to install specific python versions on the fly. In order to do this, I would need to add the following lines to the provisioning script:
```shell
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bashrc
exec "$SHELL"
pyenv install 2.7
pyenv install 3.5.6
```
This will (hopefully) add the pyenv packages from the most up-to-date release, add it to my path and then install the necessary versions of python. If I run the command `pyenv versions` it will list the python versions I have set. To test this, I have set up a basic Vagrantfile which is as follows:
```Vagrantfile
Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/xenial64"
    config.vm.provision "shell", privileged: false, inline: <<-SHELL
        sudo apt-get update
        sudo apt-get install g++
        sudo apt-get install -y git
        git clone https://github.com/pyenv/pyenv.git ~/.pyenv
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
        echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bashrc
        exec "$SHELL"
        pyenv install 2.7
        pyenv install 3.5.6
    SHELL
end
```
As you can see I have set privileged to false, this is because according to [this](https://stackoverflow.com/questions/47296428/install-pyenv-in-vagrantfile) stack overflow question, running the provisioning shell without that flag installs pyenv but only for the sudo user. 

This didn't work, sadly. However some people are geniuses who have done this all before. I came across Bogdan's [i-vagrant](https://github.com/bogdanvlviv/i-vagrant) which is seriously amazing, and these lines are in their Vagrantfile.
```Vagrantfile
# python
# config.vm.provision :shell, path: 'ubuntu/python/install-pyenv.sh', privileged: true
# config.vm.provision :shell, path: 'ubuntu/python/install-python.sh', args: 'pyenv 2.7.15', privileged: true
# config.vm.provision :shell, path: 'ubuntu/python/install-python.sh', args: 'pyenv 3.6.5', privileged: true
```
And those two scripts look as follows:

**[install-pyenv](https://github.com/bogdanvlviv/i-vagrant/blob/master/ubuntu/python/install-pyenv.sh)**
```bash
#!/usr/bin/env bash

apt update

# "ubuntu/git/install-git.sh"
apt install -y git
# "ubuntu/git/install-git.sh"

rm -fr ~/.pyenv
git clone https://github.com/pyenv/pyenv.git ~/.pyenv

sed -i "1ieval \"\$(pyenv init -)\"\n" ~/.bashrc
sed -i "1iexport PATH=\"\$PYENV_ROOT/bin:\$PATH\"" ~/.bashrc
sed -i "1iexport PYENV_ROOT=\"\$HOME/.pyenv\"" ~/.bashrc

if [[ "$SUDO_USER" ]]; then
  chown -R $SUDO_USER:$SUDO_USER ~/.pyenv/
fi
```
**[install-python](https://github.com/bogdanvlviv/i-vagrant/blob/master/ubuntu/python/install-python.sh)**
```bash
#!/usr/bin/env bash

apt install -y build-essential
apt install -y zlib1g-dev
apt install -y libreadline-dev
apt install -y libbz2-dev
apt install -y libsqlite3-dev
apt install -y libssl-dev

if [[ "$1" = "pyenv" ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"

  pyenv install $2
  pyenv global $2

  shift 2

  if (( $# )); then
    pip install $@
  fi

  if [[ "$SUDO_USER" ]]; then
    chown -R $SUDO_USER:$SUDO_USER ~/.pyenv/
  fi
else
  echo "Need to set Python environment manager pyenv" >&2
  exit 1
fi
```
This is beautiful :heart_eyes: [@bogdanvlviv](https://github.com/bogdanvlviv)

So I simply appended the following commands to my Vagrantfile:
```Vagrantfile
# python
    config.vm.provision :shell, path: 'install-pyenv.sh', privileged: true
    config.vm.provision :shell, path: 'python/install-python.sh', args: 'pyenv 2.7.15', privileged: true
    config.vm.provision :shell, path: 'python/install-python.sh', args: 'pyenv 3.6.5', privileged: true
```
And boom :boom: it worked. Now when I ssh onto the vagrant box and run `pyenv versions` I get the following output:
```shell
root@ubuntu-xenial:~# pyenv versions
  2.7.15
* 3.6.5 (set by /root/.pyenv/version)
```

## To Be Continued :eyes: