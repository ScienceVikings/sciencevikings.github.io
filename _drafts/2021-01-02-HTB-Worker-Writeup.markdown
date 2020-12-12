---
layout: post
title:  "Hack The Box - Worker Writeup"
date:   2021-01-02 06:00:00
categories: Security CTF HTB"
author: Ryan
---

*[Hack The Box](https://hackthebox.eu) is an online platform allowing you to test your penetration testing skills and exchange ideas and methodologies with thousands of people in the security field.*  
![Header](../images/HTB-Worker/Header.png)

Worker is a Medium level Windows machine. Based on the creator and community statistics, this box is highly customized and will require us to put some extra effort into the enumeration phase. 
![Statistics](../images/HTB-Worker/Statistics.png)

## Information Gathering

#### Nmap:
By scanning the target IP with Nmap, we're able to find what ports are open (`-p`), while fingerprinting the services running and their versions (`-sV`). We're also running the default set of scripts (`-sC`), which can help find additional information and automate some of our initial steps. Once the scan is completed, nmap with write the results to our Extracts folder (`-oA`)  
`>> nmap -p80,3690,5985 -sC -sV -oA Extracts/Worker 10.10.10.203`  
![Nmap](../images/HTB-Worker/nmap.png)

* **Port 80 - HTTP**: A basic IIS websever that doesn't immediately appear to be hosting content. We'll need to look around more for the proper hostnames to use.
* **Port 3690 - svnserve**: SVN, or [Subversion](https://subversion.apache.org/faq.html#why), is an open-source, centralized version control system. We can start looking here for any open files/directories to dig through.
* **Port 5985 - HTTP**: Although nmap shows this port is hosting some type of HTTP server, port 5985 is also used for [WinRM](https://docs.microsoft.com/en-us/windows/win32/winrm/portal). If we're able to find credentials, it's posible this will be our way into the machine.

### Subversion
Using the SVN CLI tool, we're able to test our ability to connect by listing out the directories and files available.  
`>> svn ls svn://10.10.10.203`  
![List](../images/HTB-Worker/Info_SVN_ls.png)

It appears we're able to successfully connect to the server. There's a `dimension.worker.htb` reference that we can add to our hosts file, as well as a directory containing the website and `moved.txt` file. Our next step is to copy down the contents to our local machine.  
`>> svn cp svn://10.10.10.203 ./svn`  
![Copy](../images/HTB-Worker/Info_SVN_cp.png)

### Worker site
Digging around the [dimension.worker.htb](http://dimension.worker.htb) site, we come across a collection of additional subdomains including `alpha`, `cartoon`, `lens`, `solid-state`, `spectral`, and `story`. None of these sites appeared to have anything of value.
![Worker](../images/HTB-Worker/Info_Worker.png)

### Version Hostory
Reading the `moved.txt` file, it looks like the latest version of the site has been migrated to [devops.worker.htb](http://devops.worker.htb).  
![Moved](../images/HTB-Worker/Info_Moved.png)

One of the main features of version control is the ability to track changes and revisit previous iterations of a file. Using the SVN CLI, we're able to check the logs for any comments that stand out as referencing the past site. 
`>> svn log svn://10.10.10.203`  
![Log](../images/HTB-Worker/Info_SVN_log.png)

Let's check out the changes lining up with r2, "Added deployment script".  
`>> svn co -r2 svn://10.10.10.203/ ./r2`  
![Checkout](../images/HTB-Worker/Info_SVN_co.png)

### Credentials
Looks like we've found Nathen's credentials in the deployment script.
![Deploy](../images/HTB-Worker/Info_Deploy.png)

## Foothold
Looking at the devops site referenced in the `moved.txt` file, we're hit with a login screen. Let's try out Nathen's credentials.  
![Devops](../images/HTB-Worker/Foothold_Devops.png)

