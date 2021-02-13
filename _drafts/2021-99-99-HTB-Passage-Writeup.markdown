---
layout: post
title:  "Hack The Box - Passage Writeup"
date:   2021-02-13 06:00:00
categories: Security CTF HTB"
author: Ryan
---

*[Hack The Box](https://hackthebox.eu) is an online platform allowing you to test your penetration testing skills and exchange ideas and methodologies with thousands of people in the security field.*  
![Header](../images/HTB-Passage/Header.png)

Jewel is an Medium level linux machine. Based on the creator and community statistics, we'll likely have a decent amount of enumeration to get through, while working off of existing CVEs, against a somewhat realistic environment.  
![Statistics](../images/HTB-Passage/Statistics.png)

## Information Gathering

### Nmap:
By scanning the target IP with Nmap, we're able to find what ports are open (`-p`), while fingerprinting the services running and their versions (`-sV`). We're also running the default set of scripts (`-sC`), which can help find additional information and automate some of our initial steps. Once the scan is completed, nmap with write the results to our Extracts folder (`-oA`)  
`>> nmap -Pn -p22,8000,8080 -sC -sV -oA Extracts/Jewel 10.10.10.211`  
![Nmap](../images/HTB-Jewel/nmap.png)

* **Port 22 - SSH**: Pretty standard port to see open on linux boxes, we can try to leverage this later on if we find credentials or private key.
* **Port 8000 - HTTP**: A basic websever hosting what appears to be an instance of [Gitweb](https://git-scm.com/book/en/v2/Git-on-the-Server-GitWeb). We should look for source code here.
* **Port 8080 - HTTP**: Another webserver, but this one is running a small blog off of an installation of [Phusion Passenger](https://www.phusionpassenger.com/).

We'll also want to add Jewel.htb to our hosts file.

### 