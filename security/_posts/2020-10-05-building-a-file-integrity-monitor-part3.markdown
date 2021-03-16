---
layout: post
title:  "Building a File Integrity Monitor - Part 3"
date:   2020-10-05 00:00:00
image: 
  path: /assets/img/security/AdvancedFIM_Part3/Header.png
author: Ryan
---

- Table of Contents
{:toc .large-only}

Hopefully you're caught up with our [previous](http://sciencevikinglabs.com/building-a-file-integrity-monitor-part2/) post, where we upgraded the hashing and added a way to collect the bytes of our files. In this post, we'll be starting to clean up the code, as well as implementing a database and config file to be used for the remainder of the project. *NOTE: Due to the depreciation of Python 2.7, we've swapped to Python3. The updated code is near identical except for print commands*

## Configure the Database
In the current state of the code, every file, hash, and byte are all being held in memory while the program runs. Our goal is to eventually rely on a single version of each file that can be carried over from one scan to the next, acting as a master backup. To accomplish this, we'll need to set up a database to store the data.

```python
import sqlite3

db = sqlite3.connect('FileIntegrityMonitor.db')
db.row_factory = sqlite3.Row
cur=db.cursor()

def configureDatabase():
  db.execute('CREATE TABLE IF NOT EXISTS Monitor (ID INTEGER PRIMARY KEY AUTOINCREMENT, Path TEXT NOT NULL, Recursive BIT NULL)')
  db.execute('CREATE TABLE IF NOT EXISTS File (ID INTEGER PRIMARY KEY AUTOINCREMENT, FilePath TEXT NOT NULL)')
  db.execute('CREATE TABLE IF NOT EXISTS Hash (ID INTEGER PRIMARY KEY AUTOINCREMENT, FileID INTEGER NOT NULL, Hash TEXT NOT NULL)')
  db.execute('CREATE TABLE IF NOT EXISTS Recovery (ID INTEGER PRIMARY KEY AUTOINCREMENT, FileID INTEGER NOT NULL, Base64 TEXT NOT NULL)')
  
configureDatabase()
```

#### Walk-through:
* **Line 1**: Our first step is to import the `sqlite3` module. This will be used to create, connect, and query our database.
* **Line 3**: Here, we set up the connection to our database 'FileIntegrityMonitor.db'. Don't worry about creating this file, as Python will do that for us.
* **Line 4**: By changing the `row_factory` property of our database object, we can tell it what format we want our data returned in. `sqlite3.Row` will let us call fields by name, allowing for more readable code.
* **Lines 8-11**: Using our database connection, we create four main tables to keep our data. These tables are `Monitor` for storing directories we wish to scan, `File` for keeping track of all the known files from each scan, `Hash` for storing the calculated hash of each file, and `Recovery` for storing the initial contents of each file.


## Adding Paths to Monitor
Now that we've got our database set up, we'll have to add our paths from the `monitor` variable used in previous scripts. I'm using [SQLiteBrowser](http://sqlitebrowser.org/) to execute these Insert statements, but feel free to use whatever works best for you or even add them to your code.

```sql
INSERT INTO Monitor([Path],[Recursive]) VALUES('C:\Users\Ryan\Dropbox\SVL\Projects\AdvancedFIM_GatherFiles',1);
INSERT INTO Monitor([Path],[Recursive]) VALUES('C:\Users\Ryan\Dropbox\SVL\Projects',0);
INSERT INTO Monitor([Path],[Recursive]) VALUES('C:\Users\Ryan\Dropbox\SVL\Projects\BasicFIM\BasicFIM.py',null);
```

#### Walk-through:
These scripts are just basic Insert statements. They tell the database what table (`Monitor`) to add the data to, which fields (`Path`, `Recursive`) are being populated, and the values being entered. Notice that we left out the ID field, as it was set to `AUTOINCREMENT` in our previous step. We'll be writing a lot more SQL throughout this post, so take a look at some of these [tutorials](http://www.tutorialspoint.com/sqlite/sqlite_syntax.htm) in case you want to learn more about how it works.


## Initialize Monitored Files
The first time we run our File Integrity Monitor, it'll need to set up a baseline to work with. This includes identifying all the files we'll need to monitor, their hashes to compare against, and a base64 encoded version of their contents we can eventually restore from.

```python
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
  ```

#### Walk-through:
* **Line 2**: Making a call to our new `getFiles()` function, we can iterate over all the files found in the directories set up in the previous step. 
* **Line 3**: Using the cursor we created, write a [parameterized query](https://www.owasp.org/index.php/SQL_Injection_Prevention_Cheat_Sheet#Defense_Option_1:_Prepared_Statements_.28with_Parameterized_Queries.29) to retrieve the first matching ID of the file from the database.
* **Lines 5-8**: If the ID is `None`, it means we have no previously stored information about this file and should create a new record for it. We do this by adding the file to the `File` table, followed by its hash and base64 values to the `Hash` and `Recovery` tables.
* **Lines 9-11**: If the file already exists in the database, we can update the hash and recovery information in case anything changed since the FIM was last ran. *Note: By running this code, we'll be updating our baseline every time the tool is ran. If files were changed while the tool wasn't running, these changes will not be detected and alerted on. You can skip this code if you'd like.*
* **Line 12**: Commit our changes to the database, essentially "Saving" what we've done.
* **Line 15**: Querying the database for all of our monitored paths, we can iterate over the results to find files.
* **Line 18**: If the path we've extracted is a directory, and we've set the recursive flag to `True`, we do a full search of the directory and all directories within it, adding all files to the `fileList`.
* **Line 20**: If the path we've extracted is a directory, but the recursive flag is set to `False`, then we add only the files in the directory, ignoring any other directories found.
* **Line 22**: If the path is not a directory, but is a valid file, add it directly to the `fileList`.

## Create Config File
Another feature we'll be adding is the ability to read from a configuration file. This is where we can store customizable values to change how the tool behaves, without having to modify the source code.

```
[Timer]
Wait: 1
```

#### Walk-through:
We can name configuration categories by placing them between `[]`, such as the `[Timer]` example above. Any configurations belonging to that category will be placed on the lines below it, and be read until another category is named, or the end of the file is reached. For this simple config file, we'll just add a `Wait`, with the value of 1. Save the file as `FileIntegrityMonitor.ini` in the same directory as our script.

## Parsing Config Files
With the configuration file created, we can test our ability to read from it. This is just a basic demonstration of the functionality we'll be adding to the larger script.

```python
import configparser

conf = configparser.ConfigParser()
conf.read('FileIntegrityMonitor.ini')

print(int(conf.get('Timer', 'Wait')))
```

#### Walk-through:
* **Line 1**: Start by importing python's `configparser` module.
* **Lines 3-4**: We can now create an instance of the `ConfigParser` class, defined as the variable `conf` and reading from our previously created `FileIntegrityMonitor.ini` file.
* **Line 6**: Here, we're getting the value of the `Wait` setting, found in the `Timer` category, and then printing it to the console.

#### Output:
![ConfigParser](/assets/img/security/AdvancedFIM_Part3/configParser.png)

## Putting It All Together
Taking all of our changes, we're able to update the previous version of the tool to include a local database for storage, a `getHash()` function, and the ability to read settings from a configuration file. Lets go over those changes here.

```python
import os,hashlib,time,base64,sqlite3,configparser

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
configureDatabase()
initializeFiles()
files=getFiles()

while True:
  for fimFile in files:
    hash=getHash(fimFile)
    storedFile=cur.execute('SELECT * FROM File F LEFT JOIN Hash H ON F.ID=H.FileID WHERE FilePath=?',(fimFile,)).fetchone()
    if storedFile != None and hash != storedFile['Hash']:
      print('%s\t%s has been changed!'%(time.strftime("%Y-%m-%d %H:%M:%S") , fimFile))
  time.sleep(int(conf.get('Timer', 'Wait')))
  ```

#### Walk-through:
* **Line 1**: Here, we're adding the sqlite3 and configparser modules to the import.
* **Lines 3-5**: At the top of the file, we're adding definitions for our sqlite database connection, row type, and cursor variables.
* **Lines 6-7**: The next lines define the ConfigParser class, and load the `FileIntegrityMonitor.ini` file we created earlier.
* **Lines 8-12**: Defining the database tables, we're able to replace the old code consisting of the monitor dictionary and directory listings
* **Lines 42-44**: Prior to entering our scanning loop, we'll need to call all the new functions we created to set up the tool's environment. This includes the databse setup with `configureDatabase()`, setting up the baseline for files with `initializeFiles()`, and generating the list of files to scan with `getFiles()`.
* **Line 48**: Previously, we were generating the hash within the loop. However, now that the functionality is used in multiple ares of the tool, it makes more sense to put it into a function.
* **Lines 49-51**: While scanning a file, we need to query for data to compare against. If that file exists in our database, and its hash is different than the files being scanned, we can print a message to the screen.
* **Line 52**: Using the new config parser, we can upgrade our previous sleep timer to read from the FIM settings, waiting one second

## Conclusion
This wraps up part 3 of building our File Integrity Monitor. We've added not only the ability to read configurations from a file, but also implemented data storage allowing us to store hashes between runs and pave the way for future features such as data recovery. In the next post, we'll be looking at setting up some alerting for when file changes take place, see you then!