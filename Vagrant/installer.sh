#!/bin/bash

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y g++
sudo apt-get install -y git
git config --global user.email "myemail@gmail.com"
git config --global user.name "Angus"
sudo apt-get install -y build-essential
sudo apt install -y default-jdk