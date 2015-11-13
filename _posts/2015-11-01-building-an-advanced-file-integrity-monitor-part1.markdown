---
layout: post
title:  "Building an advanced File Integrity Monitor - Part 1"
date:   2015-11-01 20:15:00
categories: Security Python "File Integrity Monitor"
author: Ryan
---

Last month, we posted a guide on how to make your very own [Basic File Integrity Monitor](http://sciencevikinglabs.com/building-a-basic-file-integrity-monitor/). In this six-part series, you'll be taking what you learned and replacing simple components with more advanced, realistic counterparts. This first post is all about gathering the files you'll need for monitoring.

**Note:** If you don't already have you basic FIM set up, follow the link above before continuing.


##Declaring Paths and Scan types
In our previous post, the FIM was only able to monitor files within its own directory. This greatly reduces the effectiveness of the script's monitoring abilities and is not a very good approach to take. The first change we'll make is to declare a list of files and directories we wish to watch over.

<script src="https://gist.github.com/RBoutot/205de4d8e829443ed41d.js?file=monitorVar.py"></script>

####Walk-through:
`monitor` is a simple Python list populated with a number of dictionaries. The `path` value contains the location of the file/directory, while the `recursive` value contains a boolean for the type of scan to be used. We'll put this list to use in our next step.

##Declaring the getFiles() Function
Now that we have a list of files and directories to monitor, we'll need to script up a way to read through it.

<script src="https://gist.github.com/RBoutot/205de4d8e829443ed41d.js?file=getFiles.py"></script>

####Walk-through:
* **Line 1**: We start by adding `import os` to the top of our script, giving us access to Python's built-in OS module. We'll need this for tasks like grabbing directories and determining their contents.
* **Line 9**: Declares the local variable `filesList` as an empty list. Each iteration of the Monitor will start fresh in order to detect new or deleted files.
* **Line 11**: Utilizes the `isDir()` function of `os.path`, determining whether or not our path is a directory.
* **Line 13**: To scan a directory [recursively](https://en.wikipedia.org/wiki/Recursion_%28computer_science%29), the FIM must not only locate files within the directory, but also in sub directories until it cannot continue further. To accomplish this, we use the `os` modules [walk()](https://docs.python.org/2/library/os.html#os.walk) function. This line uses a [List Comprehension](https://docs.python.org/2/tutorial/datastructures.html#list-comprehensions) in order to take a series of commands and combine them into one. As each file is located, it is added to a list and then eventually added to `filesList`. An normal version of this line is written as follows:
<script src="https://gist.github.com/RBoutot/205de4d8e829443ed41d.js?file=recursiveLong.py"></script>
* **Line 15**: In a non-recursive version of line 13, each file located within the single directory is then added to `filesList`.
* **Line 17**: If the value of `x['path']` is a file, no additional work is required. It is added to `filesList`.

####Output:
![Get Files](/images/AdvancedFIM_Part1/GetFiles.png)

##Updating the Basic FIM:
Taking what we've written so far, we can add `monitor` and `getFiles()` to the top of our existing script.

<script src="https://gist.github.com/RBoutot/205de4d8e829443ed41d.js?file=AdvancedFIM_GatherFiles.py"></script>

####Walk-through:
* **Line 21**: Replacing the original script's code with `for file in getFiles():` will allow it to iterate through the returned list from the new `getFiles()` function, instead of calculating the files in-line.

##Conclusion
You can now add and remove as many files and directories as you wish. Maybe even try experimenting with different combinations of recursive and non recursive scans to see what you come up with. This wraps up the first post in the Advanced File Integrity Monitor series, but check back soon for the next post where we calculate hashes and file bytes.
