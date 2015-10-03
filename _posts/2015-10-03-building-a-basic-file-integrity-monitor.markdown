---
layout: post
title:  "Building a basic File Integrity Monitor"
date:   2015-10-03 12:30:00
categories: Security File Integrity Monitoring FIM Python
author: Ryan
---

File Integrity Monitoring systems are great for notifying users when important files are being changed, and can even prevent the changes from sticking. In this post, I’ll show you how to build your own basic FIM using Python, alerting on changes by sending messages to the console.

**Note:** I've created a new directory for this project, and added a few junk files in addition to my `BasicFIM.py` script. You can add any files you want.


##Getting the files to monitor
The first step we'll take, is to gather up all the files in our script's directory. After all, we need something to monitor, right?

<script src="https://gist.github.com/RBoutot/45e76f0c60a8438ac8d6.js?file=GetFiles.py"></script>

####Walk-through:

* **Line 1**: We start by adding `import os` to the top of our script, giving us access to Python's built-in OS module. We'll need this for tasks like grabbing directories and determining their contents.
* **Line 3**: This line has a lot going on, so I'll break it down into pieces
  * `for item in os.listdir('.')`: The `os` module's `listdir()` function is used to retrieve all items found in a given path. Here, we use `'.'`, which is the string constant for the current working directory.
  * `if os.path.isfile(item)`: Utilizing the `os` module again, the `isFile()` function of `os.path` returns a boolean after determining whether or not our item is a file.
  * `[item for item in os.listdir('.') if os.path.isfile(item)]`: Just one of the many ways to use [List Comprehensions](https://docs.python.org/2/tutorial/datastructures.html#list-comprehensions) in Python, this code reads out as "For each of the items in the directory, add it to the list if it's a file".
* **Line 4**: A simple printing of the filename to the console

####Output:
![Get Files](/images/BasicFIM/GetFiles.png)

##Calculating the hash
There are many different types of hashes to chose from, all with varying speeds and levels of security. In a production-level FIM, you'll want to take things like calculation speed and collisions into account, but for the purposes of this post, we'll use [MD5](https://en.wikipedia.org/wiki/MD5).

<script src="https://gist.github.com/RBoutot/45e76f0c60a8438ac8d6.js?file=CalculateHash.py"></script>

####Walk-through:

* **Line 1**: Here, we add the `hashlib` module so we can access the hashing functions we'll need later.
* **Line 4**: Creates a new instance of `hashlib`'s `md5()` class.
* **Line 6**: Because we may be monitoring files larger than our available memory, we need to break them into chunks to keep the system from halting. The `iter()` function allows us to repeatedly perform a task until certain criteria is met. In this case, we are using a `lambda` to read out 2048 bytes at a time, and will stop once the file reaches its end, returning `''`.
*(Note: The reason behind 2048 is that MD5 uses a block size of 128. By using a multiple of that, we can not only read the file faster, but help to calculate the hash faster as well.)*
* **Line 7**: Using the byte chunks gathered from the previous line, we use the `hash`'s `update()` function to push the new chunk into the hash object.
* **Line 8**: Generates the MD5 hash in hexadecimal format.

####Output:
![Calculate Hash](/images/BasicFIM/CalculateHash.png)

##Storing Hashes
So now that you've got your files hashed, it's time to put them some place where you can access them later.

<script src="https://gist.github.com/RBoutot/45e76f0c60a8438ac8d6.js?file=StoreHash.py"></script>

####Walk-through:

* **Line 3**: Start by declaring a new variable, `files`, as an empty dictionary.
* **Line 10**: Python loves to make things easy. This line is actually doing two things depending on whether or not the file has already been seen. If `file` is not currently a key in `files`, it is added with its value set to `md5`. If `file` *does* exist in the keys, its value is updated to the new hash.

####Output:
![Store Hash](/images/BasicFIM/StoreHash.png)

##Send a useful alert
Here's where you get to be creative! When it comes to alerting, you have a number of options to choose from. Customize the format, come up with a creative message, write to the console, send an email or text message, the possibilities are endless!

<script src="https://gist.github.com/RBoutot/45e76f0c60a8438ac8d6.js?file=SendAlert.py"></script>

####Walk-through:

* **Line 1**: We need to import the `time` module in order to access some date/time information.
* **Line 10**: To simplify this line, I'll break it down into pieces
  * `time.strftime("%Y-%m-%d %H:%M:%S")`: Using the `time` module's `strftime()` function, we can pass it a string format for it to output. If you want to make your own format, or just learn more about `strftime()`, [check this out](https://docs.python.org/2/library/time.html#time.strftime)
  * `'%s\t%s has been changed!'%(string, string)`: This is just one of Python's many ways to [format a string](https://docs.python.org/2/library/string.html#format-examples). By replacing `%s` with string variables (`%d` for numbers), you can create strings cleanly ('no need'+' for '+'this').

  #####Output:
  ![Send Alert](/images/BasicFIM/SendAlert.png)

##Detecting the change
Because we trust the baseline hashes and only want to be alerted when they change, we need to add some sort of check to prevent our alert from always going off.

<script src="https://gist.github.com/RBoutot/45e76f0c60a8438ac8d6.js?file=DetectChanges.py"></script>

####Walk-through:

* **Line 10**: If `file` exists in the keys of `files` (preventing alerts on the first run), and `md5` is not the same as `files[file]`'s value (the file has been changed), the alert will be triggered.

####Output:
After this step, you shouldn't see anything! But that will change shortly...

##Continuously Monitor
So far, you've scanned your directory, picked out the files, collected their hashes, and added alerts. For this final step, we'll throw it all in a loop to keep the code running and start the monitoring.

<script src="https://gist.github.com/RBoutot/45e76f0c60a8438ac8d6.js?file=ContinuousMonitor.py"></script>

####Walk-through:

* **Line 4**: Creates a never-ending loop, rechecking our files with each iteration.
* **Line 14**: After each iteration, we want to make sure to pause our monitoring. Without this pause, we would occasionally run into permission issues and crash the script.

####Output:
![Continuously Monitor](/images/BasicFIM/ContinuousMonitor.png)

##Conclusion
Congratulations! You've built your very own File Integrity Monitor. Even though it's very basic, all the core fundamentals are there for you to build off of. If you are interested in learning more, check back for future posts on building a more advanced FIM (along with other security related goodies).
