---
layout: post
title:  "Building a File Integrity Monitor - Part 1"
date:   2015-11-01 20:15:00
image: 
  path: /assets/img/security/AdvancedFIM_Part1/Header.png
author: Ryan
---

- Table of Contents
{:toc .large-only}

Last month, we posted a guide on how to make your very own [Basic File Integrity Monitor](http://sciencevikinglabs.com/building-a-basic-file-integrity-monitor/). In this six-part series, you'll be taking what you learned and replacing simple components with more advanced, realistic counterparts. This first post is all about gathering the files you'll need for monitoring.

**Note:** If you don't already have your basic FIM set up, follow the link above before continuing.


## Declaring Paths and Scan types
In our previous post, the FIM was only able to monitor files within its own directory. This greatly reduces the effectiveness of the script's monitoring abilities and is not a very good approach to take. The first change we'll make is to declare a list of files and directories we wish to watch over.

```python
monitor=[
  {'path':'E:\Dropbox\SVL\Projects\AdvancedFIM_GatherFiles','recursive':True},
  {'path':'E:\Dropbox\SVL\Projects','recursive':False},
  {'path':'E:\Dropbox\SVL\Projects\BasicFIM\BasicFIM.py','recursive':False}
]
```

#### Walk-through:
`monitor` is a simple Python list populated with a number of dictionaries. The `path` value contains the location of the file/directory, while the `recursive` value contains a boolean for the type of scan to be used. We'll put this list to use in our next step.

## Declaring the getFiles() Function
Now that we have a list of files and directories to monitor, we'll need to script up a way to read through it.

```python
import os

monitor=[
  {'path':'E:\Dropbox\SVL\Projects\AdvancedFIM_GatherFiles','recursive':True},
  {'path':'E:\Dropbox\SVL\Projects','recursive':False},
  {'path':'E:\Dropbox\SVL\Projects\BasicFIM\BasicFIM.py','recursive':False}
]
def getFiles():
  filesList=[]
  for x in monitor:
    if os.path.isdir(x['path']):
      if x['recursive']:
        filesList.extend([os.path.join(root, f) for (root, dirs, files) in os.walk(x['path']) for f in files])
      else:
        filesList.extend([item for item in os.listdir(x['path']) if os.path.isfile(item)])
    elif os.path.isfile(x['path']):
      filesList.append(x['path'])
  return filesList
print getFiles()
```

#### Walk-through:
* **Line 9**: Declares the local variable `filesList` as an empty list. Each iteration of the Monitor will start fresh in order to detect new or deleted files.
* **Line 11**: Utilizes the `isDir()` function of `os.path`, determining whether or not our path is a directory.
* **Line 13**: To scan a directory [recursively](https://en.wikipedia.org/wiki/Recursion_%28computer_science%29), the FIM must not only locate files within the directory, but also in sub directories until it cannot continue further. To accomplish this, we use the `os` modules [walk()](https://docs.python.org/2/library/os.html#os.walk) function. This line uses a [List Comprehension](https://docs.python.org/2/tutorial/datastructures.html#list-comprehensions) in order to take a series of commands and combine them into one. As each file is located, it is added to a list and then eventually added to `filesList`. An normal version of this line is written as follows:
```python
for (root, dirs, files) in os.walk(x['path']):
  for f in files:
    filesList.append(os.path.join(root, f))
    ```
* **Line 15**: In a non-recursive version of line 13, each file located within the single directory is then added to `filesList`.
* **Line 17**: If the value of `x['path']` is a file, no additional work is required. It is added to `filesList`.

#### Output:
![Get Files](/assets/img/security/AdvancedFIM_Part1/GetFiles.png)

## Updating the Basic FIM:
Taking what we've written so far, we can add `monitor` and `getFiles()` to the top of our existing script.

```python
import os,hashlib,time

monitor=[
  {'path':'E:\Dropbox\SVL\Projects\AdvancedFIM_GatherFiles','recursive':True},
  {'path':'E:\Dropbox\SVL\Projects','recursive':False},
  {'path':'E:\Dropbox\SVL\Projects\BasicFIM\BasicFIM.py','recursive':False}
]
files={}
def getFiles():
  filesList=[]
  for x in monitor:
    if os.path.isdir(x['path']):
      if x['recursive']:
        filesList.extend([os.path.join(root, f) for (root, dirs, files) in os.walk(x['path']) for f in files])
      else:
        filesList.extend([item for item in os.listdir(x['path']) if os.path.isfile(item)])
    elif os.path.isfile(x['path']):
      filesList.append(x['path'])
  return filesList
while True:
  for file in getFiles():
    hash = hashlib.md5()
    with open(file) as f:
      for chunk in iter(lambda: f.read(2048), ""):
        hash.update(chunk)
    md5 = hash.hexdigest()
    if file in files and md5 <> files[file]:
      print '%s\t%s has been changed!'%(time.strftime("%Y-%m-%d %H:%M:%S") , file)
    files[file]=md5
  time.sleep(1)
  ```

#### Walk-through:
* **Line 21**: Replacing the original script's code with `for file in getFiles():` will allow it to iterate through the returned list from the new `getFiles()` function, instead of calculating the files in-line.

## Conclusion
You can now add and remove as many files and directories as you wish. Maybe even try experimenting with different combinations of recursive and non recursive scans to see what you come up with. This wraps up the first post in the File Integrity Monitor series, but check back soon for the next post where we calculate hashes and file bytes.
