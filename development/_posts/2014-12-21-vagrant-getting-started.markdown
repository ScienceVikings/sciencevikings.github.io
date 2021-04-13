---
layout: post
title:  "Vagrant Getting Started"
date:   2014-12-21 16:00:00
image:
  path: /assets/img/development/vagrant/header.png
author: Justin
---

- Table of Contents
{:toc .large-only}

## Why Vagrant?

Remember all those other projects you wanted to work on, but you had to install about a thousand things, have exactly
the right path variables setup and had to perform some voodoo ritual to get started and your object reference was still
not set to the instance of an object? Vagrant makes that pain happen only once! That’s right, if you can sucker someone
else into building your vagrant environment for you, you don’t feel any pain at all.

Vagrant lets you build a custom virtual machine from scripts and set it up so your can work from your normal
directories and IDEs. Then, when someone else wants to work in the same environment you are, they just download your
Vagrantfile and "vagrant up" their own machine.

## Install Guide
[Vagrant Download Site](https://www.vagrantup.com/downloads.html)

[Virtual Box Download Site](https://www.virtualbox.org/wiki/Downloads)

## Starting From Scratch
1. Install Vagrant and Virtual Box
2. Clone whatever repository you want to setup your image under
  * Skip this step if you already have it
3. Open a command line to your repository
  * In windows, if you have the explorer window open you can hold shift and right click to get an "Open command window
    here" option in the context menu
4. Type `vagrant init hashicorp/precise32`
  * This creates a file named Vagrantfile that contains the options used to setup the box
5. Type `vagrant up`
  * Get a cup of coffee or a beer while your image downloads
  * The image gets stored in your user profile so you don't have to download it more than once, incase you setup another
    vagrant box later for another repository.
6. Type `vagrant ssh`
  * This requires some SSH tools. If it complains, make sure [git](http://git-scm.com/downloads) is installed.
7. Hooray! You’re ssh’d into your own VM!

## Recommended Cheat Codes
1. Install Vagrant and Virtual Box as normal
2. Clone some repository that already has a Vagrantfile
3. Open the command line to your repository
4. Type `vagrant up`
5. Type `vagrant ssh`
6. Hooray! You’re ssh’d into a VM someone else setup for you!

## Vagrantfile
There are many options you can set in your vagrant file to customize your VM. Here are some that are extra common or
useful.

#### config.vm.box
This tells the virtual machine what image to build from. It can be an image you made yourself somewhere else, or it can
be an image pulled from a website somewhere.

#### config.vm.network
This config parameter lets you forward ports from your host machine to your VM. For example, if you setup your VM to
have a web server hosted on port 80, you could set port 8080 on your real machine to point directly to port 80 on the
VM.

Example: `config.vm.network "forwarded_port", guest: 80, host: 8080`

#### config.vm.synced_folder
While vagrant automatically syncs /vagrant on the VM to the folder you ran "vagrant up" in, you may want to sync up
other folders in different spots. This command lets you do it.

Example: `config.vm.synced_folder "../data", "/vagrant_data"`

The example is attaching a folder named data on the host machine to the directory /vagrant_data on the VM

#### config.vm.provision
This configuration is a lot of the bread and butter of Vagrant. This lets you run commands to setup your VM as it
boots. Take the example below

Example: `config.vm.provision :shell, path: "bootstrap.sh"`

Here we are telling vagrant to run the file bootstrap.sh, which is located in the same directory as the Vagrantfile, to
effectively set up anything else on the machine. This is a bash script that is used to run commands to install other
programs.

## Customizing Your Setup
Ok, so now you have a VM. If you didn’t use the cheat codes, that means you got suckered into setting up the VM. Vagrant
has quite a few options that will make your life easier.

The VM we setup is a Ubuntu Linux image which uses a program called apt-get to install/update programs used in the system.
To setup our machine, we can do whats called "provisioning the system." This uses the config.vm.provision function
of the Vagrantfile. To provision the system we will write a bash script that gets run once the machine is booted that
will install all our needs. Lets say we need python, pip (an easy python library installer), and a few useful python
libraries as a use case.

In the Vagrantfile, add the line `config.vm.provision :shell, path: "bootstrap.sh"`
This line is telling Vagrant to run the bootstrap.sh file using bash when we tell it to provision the system.

Next, in your repository directory create a bootstrap.sh file. This file will get run to provision the system.

Since this file is a bash file, it will run every line of the file as if we typed it into the command line ourselves.
Note that lines starting with # are comments. Our example file might look something like this:

```shell
#!/usr/bin/env bash

#Get Packages
#the -y tells the apt-get program to
#respond with "yes" to every "are you sure" question
apt-get -y update
apt-get install -y python2.7-dev
apt-get install -y curl
apt-get install -y python-pip

#Get python libraries using pip
pip install beautifulsoup4
pip install mechanize
pip install selenium
```

Now, if your vagrant isn’t already running, when you run the command `vagrant up` the system will automatically be
provisioned. If your vagrant machine is already running, that’s ok, you can just run `vagrant provision` to start
the provisioning process.

Finally your system is setup. All that’s left to do is to commit your Vagrantfile and bootstrap.sh file back to your
repository so that others can use it and start developing quickly and painlessly. Make sure they thank you for taking
one for the team and setting everything up!

## Shutting Down
When you’re ready to shut down your vagrant VM you have a couple different options.

`vagrant suspend`

This command is a "point in time" shutdown for your VM. This allows you to resume your VM quickly but requires more
disk space as it copies the entire RAM of the VM. It bring it out of a suspended state, use the `vagrant resume`
command.

`vagrant halt`

This is the same as shutting any other PC. All data in the image is saved and it can be brought back up with a simple
`vagrant up` command again.

`vagrant destroy`

This command wipes everything. It will clean up all the VM space and it will be like you never created a VM in the
first place. Don't worry about having to download the base image again though, the box itself gets stored elsewhere
so you can load up other environments more quickly.

## IDE Integration
By now you’re probably wondering, "This is all well and good, but what about my IDE? Doesn’t it need to know where
python or (insert other language here) lives to work?" If you’re using a magical IDE, like almost anything from
[JetBrains](https://www.jetbrains.com/), you can have it point to the interpreters living on your VM so you don’t need
anything installed locally other than the IDE, vagrant and virtual box. Unfortunately, remote interpreters only comes
with the paid version of JetBrain's IDEs, but they are well worth the cost. I'll leave the setting up the interpreter
as an exercise for the reader. But, I will leave a [hint](https://www.jetbrains.com/pycharm/webhelp/configuring-remote-python-interpreters.html).

