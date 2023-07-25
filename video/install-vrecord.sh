#!/usr/bin/bash

# Before running this script, compile a current version of FFmpeg

# Installing a working version of vrecord, per the instructions at

# Installing MPV
sudo add-apt-repository ppa:mc3man/mpv-tests
sudo apt-get update
sudo apt-get install mpv

# Install Dependencies
sudo apt-get install curl
sudo apt-get install gnuplot
sudo apt-get install xmlstarlet
sudo apt-get install mkvtoolnix
sudo apt-get install mediaconch

# Install Support for DV Capture

sudo apt-get install libiec61883-dev
sudo apt-get install libraw1394-dev
sudo apt-get install libavc1394-dev
sudo apt-get install libavc1394-tools

# Install Make and GCC

sudo apt-get install gcc
sudo apt-get install make

# Install FFmpeg

sudo apt-get install ffmpeg

# Install Git
sudo apt-get install git

# Install Homebrew
# https://docs.brew.sh/Homebrew-on-Linux
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >> ~/.bashrc

# COPY BLACKMAGIC DRIVERS FOR LINUX HERE: /home/linuxbrew/.linuxbrew/include
brew tap amiaopensource/amiaos
brew install decklinksdk && brew install ffmpegdecklink --with-iec61883 && brew install gtkdialog
brew install vrecord
brew uninstall --ignore-dependencies sdl2
sudo apt install libsdl2-dev
