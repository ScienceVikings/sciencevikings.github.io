---
layout: post
title:  "Building a File Integrity Monitor - Part 4"
date:   2020-11-02 00:00:00
image: 
  path: /assets/img/security/AdvancedFIM_Part4/Header.png
author: Ryan
---

- Table of Contents
{:toc .large-only}

In our [previous](http://sciencevikinglabs.com/building-a-file-integrity-monitor-part3/) post, we created a database to store all our information and added a config file to read variables from. In this post, we'll build off that config file while incorporating email alerts when changes are detected.

## Update the Config File
Because we've already done most of the groundwork, we'll be Keeping this post fairly short and simple. Setting an email account and where to send our alerts is the perfect opportunity to use the configuration file we created previously. 

```
[Timer]
Wait: 1

[Email]
Username: {SENDER'S EMAIL}
Send_To: {DESTINATION EMAIL}
```

#### Walk-through:
* **Line 4**: Here we're defining the `Email` section of the config, similar to the `Timer` section above.
* **Line 5**: Defining the `Username` propery, replace "{SENDER'S EMAIL}" with the account you plan to send the alerts from. Our code is based around Google's SMTP server, so try to use a gmail account if you can.
* **Line 6**: Our `Send_To` propery is who will be recieving the alerts. "{DESTINATION EMAIL}" can be replaced with a single email, or even a comma-deliminated list of multiple emails. For example email1@test.com,email2@website.com.

## Sending Emails
This section is the bulk of the code we'll be adding to the main script. As you can see, it doesn't take much effort on our part to send an email. They are lots of other options for sending alerts if you want to get creative. You could look at using SMS, Slack, Discord, or even push notifications.

```python
sender_email = 'sender@gmail.com'
receiver_email = 'destination@email.com'
password = getpass('Email Password: ')

msg = MIMEText(message)
msg['Subject'] = 'Alert - File Change Detected'
msg['From'] = sender_email
msg['To'] = receiver_email

with smtplib.SMTP("smtp.gmail.com", 587) as server:
  server.starttls(context=ssl.create_default_context())
  server.login(sender_email, password)
  server.sendmail(sender_email, receiver_email, msg.as_string())
  ```

#### Walk-through:
* **Lines 1-2**: These variables are where we define who we'll be sending emails as, and who will be recieving them. For testing purposes, we can just define them as strings rather than load them from the config.
* **Line 3**: We dont want to store our account password in the configuration, because it's easier for someone to find and misuse. The simplest approach we can take is to provide the password as the script starts, where it can be used for as long as the scripts runs. The `getpass()` function allows us to type a password in the terminal without displaying sensitive text on screen.
* **Lines 5-8**: Using a `MIMEText()` class, we can define all the components of the email and ensure that the recieving inbox renders everything properly.
* **Lines 10-11**: We define our server connection using Google's "smtp.google.com" over port 587 for secure SMTP. The following line tells the server to use TLS.
* **Line 12**: Here we authenticate to the server using the credentials we provided. This will allow us to send and recieve emails on behalf of the account, right in our script.
* **Line 13**: Lastly, we call the `sendmail()` method to package up our message and send it out to the people we want alerted.

## Putting It All Together
Taking our email code, we're able to update the previous version of the tool with not a whole lot of changes. The full updated script is below.

```python
import os,hashlib,time,base64,sqlite3,configparser,smtplib,ssl
from email.mime.text import MIMEText
from getpass import getpass

db = sqlite3.connect('FileIntegrityMonitor.db')
db.row_factory = sqlite3.Row
cur=db.cursor()
conf = configparser.ConfigParser()
conf.read('FileIntegrityMonitor.ini')
def configureDatabase():
	db.execute('CREATE TABLE IF NOT EXISTS Monitor (ID INTEGER PRIMARY KEY AUTOINCREMENT, Path TEXT NOT NULL, Recursive BIT NULL)')
	db.execute('CREATE TABLE IF NOT EXISTS File (ID INTEGER PRIMARY KEY AUTOINCREMENT, FilePath TEXT NOT NULL)')
	db.execute('CREATE TABLE IF NOT EXISTS Hash (ID INTEGER PRIMARY KEY AUTOINCREMENT, FileID INTEGER NOT NULL, Hash TEXT NOT NULL)')
	db.execute('CREATE TABLE IF NOT EXISTS Recovery (ID INTEGER PRIMARY KEY AUTOINCREMENT, FileID INTEGER NOT NULL, Base64 TEXT NOT NULL)')
def initializeFiles():
	for fimFile in getFiles():
		ID=cur.execute('SELECT ID FROM File WHERE FilePath=?',(fimFile,)).fetchone()
		if ID == None:
			cur.execute('INSERT INTO File(FilePath) VALUES(?)',(fimFile,))
			newID = cur.lastrowid
			cur.execute('INSERT INTO Hash(FileID,Hash) VALUES(?,?)',(newID,getHash(fimFile),))
			cur.execute('INSERT INTO Recovery(FileID,Base64) VALUES(?,?)',(newID,getBase64(fimFile),))
		else:
			cur.execute('UPDATE Hash SET Hash=? WHERE FileID=?',(getHash(fimFile),ID[0],))
			cur.execute('UPDATE Recovery SET Base64=? WHERE FileID=?',(getBase64(fimFile),ID[0],))
	db.commit()
def getFiles():
	filesList=[]
	for x in cur.execute('SELECT * FROM Monitor').fetchall():
		if os.path.isdir(x['Path']):
			if x['Recursive']:
				filesList.extend([os.path.join(root, f) for (root, dirs, files) in os.walk(x['Path']) for f in files])
			else:
				filesList.extend([item for item in os.listdir(x['Path']) if os.path.isfile(item)])
		elif os.path.isfile(x['Path']):
			filesList.append(x['Path'])
	return filesList
def getHash(fimFile):
	with open(fimFile,"rb") as f:
		bytes = f.read()
	return hashlib.sha256(bytes).hexdigest()
def getBase64(fimFile):
	return base64.b64encode(open(fimFile, "rb").read())
def sendAlert(alert):
	sender_email = conf.get('Email', 'Username')
	receiver_email = conf.get('Email', 'Send_To')

	msg = MIMEText(alert)
	msg['Subject'] = 'Alert - File Change Detected'
	msg['From'] = sender_email
	msg['To'] = receiver_email

	context = ssl.create_default_context()
	with smtplib.SMTP("smtp.gmail.com", 587) as server:
		server.starttls(context=context)
		server.login(sender_email, password)
		server.sendmail(sender_email, receiver_email, msg.as_string())

configureDatabase()
initializeFiles()
files=getFiles()
password = getpass('Email Password: ')

while True:
	for fimFile in files:
		hash=getHash(fimFile)
		storedFile=cur.execute('SELECT * FROM File F LEFT JOIN Hash H ON F.ID=H.FileID WHERE FilePath=?',(fimFile,)).fetchone()
		if storedFile != None and hash != storedFile['Hash']:
			sendAlert('%s:\t%s has been changed!'%(time.strftime("%Y-%m-%d %H:%M:%S") , fimFile))
			exit()
	time.sleep(int(conf.get('Timer', 'Wait')))
```

#### Walk-through:
* **Lines 1-3**: We start by adding the `smtplib` and `ssl` modules, followed by `MIMEText` and `getpass`.
* **Line 44**: Defining a `sendAlert()` function, we can pass in the alert message we want to send.
* **Lines 44-45**: Dont forget to update the `sender_email` and `reciever_email` to read from the config file.
* **Line 62**: We moved the password definition to the start of our script, so it will be available inside the while loop without having to enter it every time there's a change detected.
* **Line 69**: Instead of printing a message to the console, we've now changed `print()` to be our `sendAlert()` function.
* **Line 70**: In the tool's current state, we would be sending an email every second after a change is found. For now, let's exit and prevent spamming. The upcoming changes will adress this issue.

#### Output:
![Email Sent](/assets/img/security/AdvancedFIM_Part4/email.png)

## Conclusion
This wraps up part 4 of building our File Integrity Monitor. With our new email-based alerting, we'll be notified of any changes made even when we're not at our machine. In the next post, we'll be looking at adding the last piece of functionality, restoring modified files to their approved versions.