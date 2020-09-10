---
layout: post
title:  "Building a File Integrity Monitor - Part 2"
date:   2015-11-27 11:20:00
categories: Security Python "File Integrity Monitor"
author: Ryan
---

Welcome back for part two in this six part series of building your own File Integrity Monitor. In this post, we'll be upgrading the MD5 hashing to SHA-256, as well as grabbing the Base64 encoded bytes of our files.

There isn't a whole lot of work to do in this post, so I'd like to start off by writing a bit about MD5, and why it is not a good fit for our project.

**Note:** If you haven't completed [Part 1](http://sciencevikinglabs.com/building-a-file-integrity-monitor-part1/) of this series, check that out before continuing.

## MD5: What is it?
MD5, or Message Digest 5, is a hashing algorithm commonly used for checking data integrity. It can be seen on download pages as a checksum, used in databases for hashing passwords, and even found in other FIMs.

Having been around for almost three decades, researchers have had plenty of time to poke and prod the algorithm, finding a number of weaknesses within it. This include an increasingly rapid rate of collision generation due to improving technology, and a growing number of Rainbow-Tables that allow for quick matching of known hashes.

Because of these issues, MD5 is not recommended for use in secure systems, or in any application requiring data integrity.

## Difference between MD5 and SHA-256
SHA-256 is part of the Secure Hashing Algorithm family and is considered to be the new standard in hashing.

Check out the hashes generated for the string "Science Vikings":

* MD5: 8aecf444e829fd7717cd4c3ad57f80c1
* SHA-256: 55168a73fd9e98e5fef9ae8fe615cf78445613d384ffe4a4b01a812f78975451

As you can see, the SHA-256 output is twice as long as the MD5 hash. This is because SHA-256 uses twice as many bits, giving it a much higher resistance to collisions but also a slightly longer calculation time.

![Hash Times](/images/AdvancedFIM_Part2/HashTime.png)

The above times (in seconds) are based on larger files, as you won't see much change until you're dealing with gigabytes and terabytes worth of data. SHA-256 ends up taking roughly 30% longer than MD5, but this is negligible compared to what we gain in security.

## Upgrading MD5
Now that we've got a basic understanding of MD5, let's get rid of it.

<script src="https://gist.github.com/RBoutot/32553b470ccb89b29cde.js?file=updateMD5.py"></script>

#### Walk-through:
Pretty straight forward changes, so we'll go over it quickly. Because we're already importing Python's `hashlib` module, we can access all the [other hashes](https://docs.python.org/2/library/hashlib.html) within it. By simply replacing `hashlib.md5()` with `hashlib.sha256()`, the upgrade process is complete.

I also went through and renamed all instances of the `md5` variable with `sha356` to avoid any confusion later.

## Retrieve Bytes from files
In my original post on [Basic File Integrity Monitors](http://sciencevikinglabs.com/building-a-basic-file-integrity-monitor/), I mentioned that some FIMs can actually prevent changes from sticking. Retrieving bytes from our known safe files is the first step towards accomplishing this goal in our own FIM.

<script src="https://gist.github.com/RBoutot/32553b470ccb89b29cde.js?file=getBytes.py"></script>

#### Walk-through:
* **Line 1**: In addition the the `os` and `hashlib` modules you're already familiar with, the `base64` library will be imported as well.
* **Line 3**: Declaring a variable `file` to pass to the `getBytes()` function.
* **Line 6**: Returns output of the `base64` module's `b64encode()` function after passing it the file in "read binary" mode.

### output
![getBytes()](/images/AdvancedFIM_Part2/GetBytes.png)

## Adding getBytes() to the main script
Now that we have a working `getBytes()` function going, let's add it to our main script. We'll also want to update our code to store the new data in our `files` variable.

<script src="https://gist.github.com/RBoutot/32553b470ccb89b29cde.js?file=AdvancedFIM_CalculateHash.py"></script>

### Walk-through
* **Line 20**: Added the `getBytes()` function to the script.
* **Line 31**: The previous script set dictionary values to a string containing the hash. This updated line will now set the value to a dictionary containing the SHA-256 hash and base64 output from `getBytes()`.

## Conclusion
This wraps up part two of building our FIM. We've now helped to secure our detection against collisions, as well as prepare our script for self-healing capabilities. In the upcoming post, we'll be taking a look at implementing a database for storage, so be sure to check back soon.
