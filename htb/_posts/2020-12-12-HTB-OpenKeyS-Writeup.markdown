---
layout: post
title:  "Hack The Box - OpenKeyS Writeup"
date:   2020-12-12 06:00:00
categories: "htb"
author: Ryan
---

*[Hack The Box](https://hackthebox.eu) is an online platform allowing you to test your penetration testing skills and exchange ideas and methodologies with thousands of people in the security field.*  
![Header](../images/HTB-OpenKeyS/Header.png)

OpenKeyS is a Medium level OpenBSD machine. Based on the community statistics, it looks like we'll be focusing primarily on leveraging existing CVEs. 
![Statistics](../images/HTB-OpenKeyS/Statistics.png)

## Information Gathering

#### Nmap:
By scanning the target IP with Nmap, we're able to find what ports are open (`-p`), while fingerprinting the services running and their versions (`-sV`). We're also running the default set of scripts (`-sC`), which can help find additional information and automate some of our initial steps. Once the scan is completed, nmap will write the results to our Extracts folder (`-oA`)  
`>> nmap -p22,80 -sC -sV -oA Extracts/OpenKeyS 10.10.10.199`  
![Nmap](../images/HTB-OpenKeyS/nmap.png)

* **Port 22 - SSH**: Pretty standard port to see open on linux boxes, we can try to leverage this later on if we find credentials or private key.
* **Port 80 - HTTP**: A basic websever hosting what appears to be a login for "OpenKeyS".

### OpenKeyS
One of the first things we see when loading up [10.10.10.199](http://10.10.10.199) is the login. At the top of the screen, we can also see the title "OpenKeyS - Retrieve your OpenSSH Keys".

What happens why we try the credentials `admin` and `password`?  
![Login](../images/HTB-OpenKeyS/Info_Denied.png)

### Directory Enumeration
Lets kick off a scan using Gobuster. This will allow us to enumerate any paths and files we can use to find additional information. We can point the tool at the desired url (`-u`) while passing in a list of directories and filenames to look for (`-w`). Because our wordlist may not contain all the file extensions we care about, we can specify endings like php and txt (`-x`). Lastly, there are thousands of calls being made, so speeding up the tool with higher threads can help (`-t`).  
`>> gobuster dir -u http://10.10.10.199 -w /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt -x php,txt -t 100`  
![Gobuster](../images/HTB-OpenKeyS/Info_Gobuster.png)

Navigating to [10.10.10.199/includes](http://10.10.10.199/includes) shows us a directory containing two files, [auth.php](http://10.10.10.199/includes/auth.php), and [auth.php.swp](http://10.10.10.199/includes/auth.php.swp). Looking at the details of the latter discloses the username "jennifer", perhaps this is the username we need to login?  
![File Command](../images/HTB-OpenKeyS/Info_File.png)

### Code Review
In addition to the username, we also learn that the file originated in Vim. By loading the file in recovery mode, we're able to read its contents and learn more about how the application handles its auth.  
![Auth Code](../images/HTB-OpenKeyS/Info_Code.png)

The piece worth looking at here is in the `init_session()` function, where it's setting the session username with `$_REQUEST['username']`. This tells the server to retrieve the value of `username` from not only the body of the request, but also from the cookies.

### Searching for vulnerabilities
The fact that most boxes on Hack The Box are Windows and Linux-based makes the creator's OpenBSD choice a little suspicious. After focusing on vulnerabilities around authentication in OpenBSD, one particular [article](https://www.qualys.com/2019/12/04/cve-2019-19521/authentication-vulnerabilities-openbsd.txt) stands out. It appears that by substituting a username with `-schallenge`, we're able to bypass the authentication. Let's try it out:  
![SChallenge](../images/HTB-OpenKeyS/Info_SChallenge.png)

Interesting, while our bypass seems to have worked, there is no OpenSSH Key found for our user.

## Foothold

### Traffic Manipulation
Knowing we have a way to bypass the authentication, and a potential username, let's intercept the request in Burpsuite and modify it. Burpsuite is a tool for proxying, manipulating, and scanning web traffic making it extremely beneficial to use when tinkering with requests. Here, we've intercepted our -schallenge request, and added a username cookie with the value set to jennifer. This should combine our authentication bypass with the `$_REQUEST['username']` weakness we discovered earlier.  
![Cookie](../images/HTB-OpenKeyS/Foothold_Cookie.png)

Success! Forwarding that manipulated traffic results in tricking the server into sending us back the OpenSSH Key for Jennifer.  
![Key](../images/HTB-OpenKeyS/Foothold_Key.png)

### SSH
We should now be able to remote into the machine as Jennifer using her private key.  
`>> ssh -i Extracts/jennifer.key jennifer@10.10.10.199`  
![Jennifer](../images/HTB-OpenKeyS/Foothold_Jennifer.png)

### User Flag
`>> cat user.txt`  
![User](../images/HTB-OpenKeyS/Foothold_Flag.png)

## Privilege Escalation
Keeping in mind that we're targetting an OpenBSD machine, we can research different exploits allowing us to escalate privileges. While there were a number of options available, [this](https://raw.githubusercontent.com/bcoles/local-exploits/master/CVE-2019-19520/openbsd-authroot) exploit appears to work just fine.  
`>> ./exploit.sh`  
![Exploit](../images/HTB-OpenKeyS/PrivEsc_Exploit.png)

### Root Flag
`>> cat /root/root.txt`  
![Root](../images/HTB-OpenKeyS/PrivEsc_Flag.png)