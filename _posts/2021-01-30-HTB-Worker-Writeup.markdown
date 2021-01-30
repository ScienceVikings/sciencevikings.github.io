---
layout: post
title:  "Hack The Box - Worker Writeup"
date:   2021-01-30 00:00:00
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
* **Port 5985 - HTTP**: Although nmap shows this port is hosting some type of HTTP server, port 5985 is also used for [WinRM](https://docs.microsoft.com/en-us/windows/win32/winrm/portal). If we're able to find credentials, it's possible this will be our way into the machine.

### Subversion
Using the SVN CLI tool, let's connect to the server and list out the directories and files available.   
`>> svn ls svn://10.10.10.203`  
![List](../images/HTB-Worker/Info_SVN_ls.png)

There's a `dimension.worker.htb` reference that we can add to our hosts file, as well as a directory containing the website and `moved.txt` file. Our next step is to copy down the contents to our local machine.  
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

### Authentication
Navigating to the devops site referenced in the `moved.txt` file, we're hit with a login screen. Let's try out Nathen's credentials.  
![Devops](../images/HTB-Worker/Foothold_Devops.png)  

### Azure DevOps
Azure DevOps is a platform for storing, testing, and deploying source code using the CI/CD (Continuous Integration / Continuous Delivery) framework. As changes are commited, Azure DevOps has all the information it needs to access and make updates to resources. We should be able to leverage our access here, leading to additional compromise.  
![Devops Authenticated](../images/HTB-Worker/Foothold_Devops_2.png) 

## Foothold

### Deploying our Webshell
From the Spectral Repository, we'll first create a new branch for us to make changes to.  
![Branch](../images/HTB-Worker/Foothold_Branch.png)  

Upload our [ASPX Webshell](https://github.com/nikicat/web-malware-collection/blob/master/Backdoors/ASP/aspxshell.aspx.txt) to the branch.  
![Upload](../images/HTB-Worker/Foothold_Upload.png)  

With our changes made, we can create a pull request to merge them in and trigger the CI/CD process. This will deploy the shell to [http://spectral.worker.htb/shell.aspx](http://spectral.worker.htb/shell.aspx)  
![Pull Request](../images/HTB-Worker/Foothold_PullRequest.png) 

Applying the final touches to the PR, we're able to approve it and get it deployed.  
![Pull Request Complete](../images/HTB-Worker/Foothold_PullRequest_2.png) 

### Webshell
Navigating to our [Webshell](http://spectral.worker.htb/shell.aspx), we're able to look around the machine for interesting files and information. Located in the `W:/svnrepos/www/conf/` directory, a passwd file contains credentials for a wide range of users.  
![Credentials](../images/HTB-Worker/Foothold_Credentials.png)  

Comparing the discovered credentials with the list of users we see in the `C:/Users/` directory, it looks like user `robisl` will be our way in.  
![Users](../images/HTB-Worker/Foothold_Users.png)  

### WinRM
Now that we have credentials for the target box, we can user Evil-WinRM to get a shell.  
`>> evil-winrm -i 10.10.10.203 -u robisl -p wolves11`  
![WinRM](../images/HTB-Worker/Foothold_WinRM.png) 

### User Flag
`>> type ../Desktop/user.txt`  
![User Flag](../images/HTB-Worker/User_Flag.png)  

## Privilege Escalation
Using robisl's credentials, let's try to log into the Azure DevOps platform and see what kind of access he has.  
![Devops](../images/HTB-Worker/PrivEsc_Devops.png)  

### Azure DevOps Pipeline
Another feature of Azure DevOps is the ability to create build pipelines. A pipeline is a representation of the automation process that runs to build and test an application. The automation process is just a collection of tasks that we can define. We should be able to use this feature to execute commands on the server.

Navigate to `Pipelines` > `New Pipeline`  
![Pipeline](../images/HTB-Worker/PrivEsc_Pipeline.png)  

Select `Azure Repos Git`  
![Pipeline 2](../images/HTB-Worker/PrivEsc_Pipeline_2.png)  

Choose the `PartsUnlimited` repository, and then the `Starter Pipeline`. Here, we'll update the pipline to print out the contents of the root flag file right into its output.  
![Pipeline 3](../images/HTB-Worker/PrivEsc_Pipeline_3.png)  

### Root Flag
![Root Flag](../images/HTB-Worker/Root_Flag.png)  