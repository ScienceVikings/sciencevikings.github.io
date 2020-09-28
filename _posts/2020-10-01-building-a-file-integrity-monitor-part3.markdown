---
layout: post
title:  "Building a File Integrity Monitor - Part 3"
date:   2020-10-05 12:00:00
categories: Security Python "File Integrity Monitor"
author: Ryan
---

Hopefully you're caught up with our [previous](http://sciencevikinglabs.com/building-a-file-integrity-monitor-part2/) post, where we upgraded the hashing and added a way to collect the bytes of our files. In this post, we'll be starting to clean up the code, as well as implementing a database and config file to be used for the remainder of the project. *NOTE: Due to the depreciation of Python 2.7, we've swapped to Python3. The updated code is near identical except for print commands*

## Configure the Database
In the current state of the code, every file, hash, and byte are all being held in memory while the program runs. Our goal is to eventually rely on a single version of each file that can be carried over from one scan to the next, acting as a master backup. To accomplish this, we'll need to set up a database to store the data.

<script src="https://gist.github.com/RBoutot/86f35bc3fa283974c33f.js?file=ConfigureDatabase.py"></script>

#### Walk-through:
* **Line 1**: Our first step is to import the `sqlite3` module. This will be used to create, connect, and query our database.
* **Line 3**: Here, we set up the connection to our database 'FileIntegrityMonitor.db'. Don't worry about creating this file, as Python will do that for us.
* **Line 4**: By changing the `row_factory` property of our database object, we can tell it what format we want our data returned in. `sqlite3.Row` will let us call fields by name, allowing for more readable code.
* **Lines 8-11**: Using our database connection, we create four main tables to keep our data. These tables are `Monitor` for storing directories we wish to scan, `File` for keeping track of all the known files from each scan, `Hash` for storing the calculated hash of each file, and `Recovery` for storing the initial contents of each file.


## Adding Paths to Monitor
Now that we've got our database set up, we'll have to add our paths from the `monitor` variable used in previous scripts. I'm using [SQLiteBrowser](http://sqlitebrowser.org/) to execute these Insert statements, but feel free to use whatever works best for you or even add them to your code.

<script src="https://gist.github.com/RBoutot/86f35bc3fa283974c33f.js?file=InsertData.sql"></script>

#### Walk-through:
These scripts are just basic Insert statements. They tell the database what table (`Monitor`) to add the data to, which fields (`Path`, `Recursive`) are being populated, and the values being entered. Notice that we left out the ID field, as it was set to `AUTOINCREMENT` in our previous step. We'll be writing a lot more SQL throughout this post, so take a look at some of these [tutorials](http://www.tutorialspoint.com/sqlite/sqlite_syntax.htm) in case you want to learn more about how it works.


## Initialize Monitored Files
The first time we run our File Integrity Monitor, it'll need to set up a baseline to work with. This includes identifying all the files we'll need to monitor, their hashes to compare against, and a base64 encoded version of their contents we can eventually restore from.

<script src="https://gist.github.com/RBoutot/86f35bc3fa283974c33f.js?file=InitializeFiles.py"></script>

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

<script src="https://gist.github.com/RBoutot/86f35bc3fa283974c33f.js?file=FileIntegrityMonitor.INI"></script>

#### Walk-through:
We can name configuration categories by placing them between `[]`, such as the `[Timer]` example above. Any configurations belonging to that category will be placed on the lines below it, and be read until another category is named, or the end of the file is reached. For this simple config file, we'll just add a `Wait`, with the value of 1. Save the file as `FileIntegrityMonitor.ini` in the same directory as our script.

## Parsing Config Files
With the configuration file created, we can test our ability to read from it. This is just a basic demonstration of the functionality we'll be adding to the larger script.

<script src="https://gist.github.com/RBoutot/86f35bc3fa283974c33f.js?file=ConfigParser.py"></script>

#### Walk-through:
* **Line 1**: Start by importing python's `configparser` module.
* **Lines 3-4**: We can now create an instance of the `ConfigParser` class, defined as the variable `conf` and reading from our previously created `FileIntegrityMonitor.ini` file.
* **Line 6**: Here, we're getting the value of the `Wait` setting, found in the `Timer` category, and then printing it to the console.

#### Output:
![ConfigParser](../images/AdvancedFIM_Part3/configParser.png)

## Putting It All Together
Taking all of our changes, we're able to update the previous version of the tool to include a local database for storage, a `getHash()` function, and the ability to read settings from a configuration file. Lets go over those changes here.

<script src="https://gist.github.com/RBoutot/86f35bc3fa283974c33f.js?file=AdvancedFIM_DataStorage.py"></script>

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