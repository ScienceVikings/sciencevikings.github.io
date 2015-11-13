---
layout: post
title:  "Talking to Processes with Node"
date:   2015-11-13 10:40:00
categories: nodejs
author: Justin
---

I'm currently working on a project that is being written using GitHub's [Electron](https://github.com/atom/electron).
It's great because it allows me to write desktop applications using HTML5, Javascript and CSS for the view. It allows
me to use NodeJS to do the heavy logic and other non-view things.

This is great and NodeJS offers a lot in terms of libraries, but I got a little stuck. I wanted to use a specific
Windows capability that was pretty low level. I dug around for a long while and couldn't find any NodeJS native
extensions for this functionality.

I was kind of bummed because it wasn't a particularly difficult piece of logic to implement, so I decided I'd go ahead
and write my own native module and share it with the world.

I scoured the web and figured out all the things I needed to download and install to get started. Then I pulled down an
example NodeJS native module solution and thought I'd build off from there. That would've been perfect... if I could've
gotten the darn thing to compile. I was running out of time and finding Windows solutions for NodeJS C++ code was not
simple. I got frustrated and put it down for the night to sleep on it.

The next day, I realized that I was thinking **way** too hard about this. I knew that I could implement the Windows specific
functionality in C# really easily. Then it dawned on me, I could make the functionality a C# Console application
and interact with it through the `child_process` library in NodeJS with the standard in and standard out streams!

It worked out great, and now if I want to go cross platform, all I need to do is write the equivalent program for the other
platform.

So in this post I want to show you how to create a very simple console application in C# that you can talk to with NodeJS.
The example will be trivial, but you will be able to see how to expand it for other needs.

## The C# Side

Lets jump straight to the code. If you're unfamiliar with C#, just look in the `Main` function and ignore all the stuff
around it.

{% gist f31d06f34b2977ddc8c6 csharp.cs %}

First, we just output a string saying that our app has started. Next, we loop forever and listen for incoming data on the
standard in stream.

If the data we get is the string "ping" we write "pong" to the standard out stream. The final line in that `while` loop
is just a sleep to give Windows some time to schedule another task. If we didn't have that there, our program would use
100% of the CPU.

To make sure this works, compile and run it. You should be able to type `ping` and the program output `pong`.

## The NodeJS Side

Now lets look at how we can use that executable in NodeJS.

{% gist f31d06f34b2977ddc8c6 node.js %}

First, you see we bring in the `child_process` library that will let us open other processes. The `path` variable is where
our C# executable lives. We'll use that in the next line to open it with the `spawn` function.

You'll notice an empty array being passed after the file we want to open. In this scenario I'm not using it, but that is
where you'd pass any arguments you might need to your child process.

Now we want to listen for a few things so we setup those listeners next. The `client.stderr.on` listener will get fired
if our child process throws and error and writes it to the standard error stream.

The `client.stdout.on` listener will get fired when our child process outputs anything on it's standard out stream. So this
should get fired twice when we run the script. Once from the "Started!" output from our C# program, and another time
when it responds to our "ping" command.

Then, you'll see `client.on('error')`. This is useful to get any information from the spawn command. If it can't find the
file you're trying to open, this will get triggered.

Finally, you'll see the `client.stdin.write` call. This is where we send the "ping" command to our child process. After
that command, it should reply with "pong".

## Conclusion

As you can see, it's pretty simple to interact with other processes using NodeJS. For me, this was a **much** more
maintainable, and simple solution to get Windows specific functionality into my NodeJS application. I didn't have to
learn any V8 or NodeJS C++ specifics. I didn't have to figure out how to get a native module to compile on my machine.
All I had to do was write a C# application, and have it output the information I cared about to standard out.

I'm sure there are arguments for writing native modules over using processes, but unless you're doing some crazy real-time
thing you can more than likely get away with a platform specific application to spawn from NodeJS to save yourself
a huge headache.
