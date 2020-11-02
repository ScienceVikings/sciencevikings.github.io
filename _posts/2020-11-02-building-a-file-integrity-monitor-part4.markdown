---
layout: post
title:  "Building a File Integrity Monitor - Part 4"
date:   2020-11-02 00:00:00
categories: Security Python "File Integrity Monitor"
author: Ryan
---

In our [previous](http://sciencevikinglabs.com/building-a-file-integrity-monitor-part3/) post, we created a database to store all our information and added a config file to read variables from. In this post, we'll build off that config file while incorporating email alerts when changes are detected.

## Update the Config File
Because we've already done most of the groundwork, we'll be Keeping this post fairly short and simple. Setting an email account and where to send our alerts is the perfect opportunity to use the configuration file we created previously. 

<script src="https://gist.github.com/RBoutot/e664be73bbb83995c8c6dc15c1d5c8f9.js?file=FileIntegrityMonitor.INI"></script>

#### Walk-through:
* **Line 4**: Here we're defining the `Email` section of the config, similar to the `Timer` section above.
* **Line 5**: Defining the `Username` propery, replace "{SENDER'S EMAIL}" with the account you plan to send the alerts from. Our code is based around Google's SMTP server, so try to use a gmail account if you can.
* **Line 6**: Our `Send_To` propery is who will be recieving the alerts. "{DESTINATION EMAIL}" can be replaced with a single email, or even a comma-deliminated list of multiple emails. For example email1@test.com,email2@website.com.

## Sending Emails
This section is the bulk of the code we'll be adding to the main script. As you can see, it doesn't take much effort on our part to send an email. They are lots of other options for sending alerts if you want to get creative. You could look at using SMS, Slack, Discord, or even push notifications.

<script src="https://gist.github.com/RBoutot/e664be73bbb83995c8c6dc15c1d5c8f9.js?file=EmailAlerts.py"></script>

#### Walk-through:
* **Lines 1-2**: These variables are where we define who we'll be sending emails as, and who will be recieving them. For testing purposes, we can just define them as strings rather than load them from the config.
* **Line 3**: We dont want to store our account password in the configuration, because it's easier for someone to find and misuse. The simplest approach we can take is to provide the password as the script starts, where it can be used for as long as the scripts runs. The `getpass()` function allows us to type a password in the terminal without displaying sensitive text on screen.
* **Lines 5-8**: Using a `MIMEText()` class, we can define all the components of the email and ensure that the recieving inbox renders everything properly.
* **Lines 10-11**: We define our server connection using Google's "smtp.google.com" over port 587 for secure SMTP. The following line tells the server to use TLS.
* **Line 12**: Here we authenticate to the server using the credentials we provided. This will allow us to send and recieve emails on behalf of the account, right in our script.
* **Line 13**: Lastly, we call the `sendmail()` method to package up our message and send it out to the people we want alerted.

## Putting It All Together
Taking our email code, we're able to update the previous version of the tool with not a whole lot of changes. The full updated script is below.

<script src="https://gist.github.com/RBoutot/e664be73bbb83995c8c6dc15c1d5c8f9.js?file=AdvancedFIM_EmailAlerts.py"></script>

#### Walk-through:
* **Lines 1-3**: We start by adding the `smtplib` and `ssl` modules, followed by `MIMEText` and `getpass`.
* **Line 44**: Defining a `sendAlert()` function, we can pass in the alert message we want to send.
* **Lines 44-45**: Dont forget to update the `sender_email` and `reciever_email` to read from the config file.
* **Line 62**: We moved the password definition to the start of our script, so it will be available inside the while loop without having to enter it every time there's a change detected.
* **Line 69**: Instead of printing a message to the console, we've now changed `print()` to be our `sendAlert()` function.
* **Line 70**: In the tool's current state, we would be sending an email every second after a change is found. For now, let's exit and prevent spamming. The upcoming changes will adress this issue.

#### Output:
![Email Sent](../images/AdvancedFIM_Part4/email.png)

## Conclusion
This wraps up part 4 of building our File Integrity Monitor. With our new email-based alerting, we'll be notified of any changes made even when we're not at our machine. In the next post, we'll be looking at adding the last piece of functionality, restoring modified files to their approved versions.