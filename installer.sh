#!/bin/bash

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y g++
git config --global user.email "angusmackenzie@gmail.com"
git config --global user.name "Angus Mackenzie"
sudo apt-get install -y git
chmod 777 install-pyenv.sh
chmod 777 install-python.sh
sudo /bin/bash ./install-pyenv.sh
sudo /bin/bash ./install-python.sh pyenv 2.7.15
sudo /bin/bash ./install-python.sh pyenv 3.6.5
sudo apt-get install -y build-essential
sudo apt install -y default-jdk
sudo apt install -y curl
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' 
sudo apt-get install -y apt-transport-https
sudo apt-get update
sudo apt-get install -y code
code --install-extension ms-vscode.cpptools
code --install-extension redhat.java
code --install-extension yzhang.markdown-all-in-one
code --install-extension ms-python.python
code --install-extension wakatime.vscode-wakatime
rm microsoft.gpg