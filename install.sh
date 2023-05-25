#!/bin/bash

# Add apt repositories
sudo add-apt-repository ppa:git-core/ppa
sudo add-apt-repository ppa:ubuntu-toolchain-r/test

# Sanity update and upgrade
sudo apt update && sudo apt upgrade -y

# Install packages
sudo apt install apt-transport-https bat ca-certificates clang cmake curl dash dos2unix g++ gcc gh git net-tools python-is-python3 tree wslu zsh zoxide -y

# Directories
mkdir $ZSH_CUSTOM/plugins/zsh-smartcache
mkdir $ZSH_CUSTOM/plugins/evalcache

# Install oh-my-zsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
wget "https://raw.githubusercontent.com/QuarticCat/zsh-smartcache/main/zsh-smartcache.plugin.zsh" -O $ZSH_CUSTOM/plugins/zsh-smartcache/zsh-smartcache.plugin.zsh
wget "https://raw.githubusercontent.com/mroth/evalcache/master/evalcache.plugin.zsh" -O $ZSH_CUSTOM/plugins/evalcache/evalcache.plugin.zsh

# Install starship
curl -sS https://starship.rs/install.sh | sh
