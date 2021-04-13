---
layout: post
title:  "Extracting Windows Icons with NodeJS"
date:   2015-12-15 15:20:00
author: Justin
image:
  path: /assets/img/development/icon-extraction/header.jpg
---

In an earlier [post](% post_url 2015-11-13-talking-to-processes-with-node %) I spoke about talking to NodeJS processes using good old standard in and standard
out streams. I did mention I was using it for a project, but I didn't go into too many details about it. Well, part of the project was trying to get access
to icon image data for files in windows.

I figured it would be useful for someone eventually, so I made an npm package for it and open sourced the code. Information is available at [GitHub](https://github.com/ScienceVikings/IconExtractor) and pull requests would be appreciated.

I'd like to use this post to go over the code in more detail and explain what is going on and how this works. Initially, I was hoping someone had already
written this, but my Google-Fu failed me and I was unable to figure out how to get image data for windows icons in node.

I decided it would be easiest to make a .Net application that took in some path information and output the icon data in Base64 format to standard out.
So lets check out the .Net side of things first, then take a look at how the NodeJS side is using the application.

## .NET Icon Extraction
I haven't done any .NET for a long while, so I used this [Microsoft](https://msdn.microsoft.com/en-us/library/ms404308%28v=vs.110%29.aspx?f=255&MSPPError=-2147217396)
documentation to learn how to get the data for a specific path. Now all we need to do is convert it to Base64 and print it to standard out, right? Turns output
a little more house keeping was needed. Here is the code

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.Drawing;
using System.IO;
using Newtonsoft.Json;

namespace IconExtractor {

  class IconRequest {

    public string Context { get; set; }
    public string Path { get; set; }
    public string Base64ImageData { get; set; }

  }

  class Program {
    static void Main(string[] args) {

      // https://msdn.microsoft.com/en-us/library/ms404308%28v=vs.110%29.aspx?f=255&MSPPError=-2147217396
      
      Console.InputEncoding = UTF8Encoding.UTF8;
      Console.OutputEncoding = UTF8Encoding.UTF8;

      while (true) {

        string input = Console.In.ReadLine().Trim();
        IconRequest data = JsonConvert.DeserializeObject<IconRequest>(input);

        try {

          data.Base64ImageData = getIconAsBase64(data.Path);
          Console.WriteLine(JsonConvert.SerializeObject(data));

        } catch (Exception ex) {
          Console.Error.WriteLine(ex);
          Console.Error.WriteLine(input);
        }

      }

    }

    static string getIconAsBase64(string path) {
      if (!File.Exists(path)) {
        return "";
      }

      Icon iconForPath = SystemIcons.WinLogo;
      iconForPath = Icon.ExtractAssociatedIcon(path);

      ImageConverter vert = new ImageConverter();
      byte[] data = (byte[])vert.ConvertTo(iconForPath.ToBitmap(), typeof(byte[]));

      return Convert.ToBase64String(data);
    }
  }
}
```

Looking through the `using` statements, all I've added was the Newtonsoft.Json package through NuGet.
This allows me to easily manipulate data to and from JSON, which Node uses natively so it made a lot of sense and made things much easier.

Next we see the `IconRequest` class. It has three properties, Context, Path and Base64ImageData. The reason I needed
to break this information out was because the Node side of things is using this asynchronously.

In order to know which piece of data went with which request, I require the Node side to pass in some context that this program passes back along with the Base64ImageData field filled in. In some cases, the Path could be used as the context, but for my needs, it wasn't enough.

The Path property is the path of the file we're getting the icon data from.

In the `Main` function, the first thing we do is make sure the encoding of standard in and out are both set to UTF8.
NodeJS uses UTF8 encoding by default, so setting it from the .Net side makes life much easier. No funny symbols coming across messing up JSON encoding or decoding!

Then, we start a while loop that lets the program run forever. Since we're using this much like a server, we don't want it to go away until we tell it to.

The next step is to read the JSON request in from standard in, trim it and convert it from a JSON string to our `IconRequest` object. Using that object, we pass the path through to our function that gets the Base64 image data of our icon and set it back to that object.

From there we just serialize the request back into JSON and write it back to standard out for NodeJS to read.

The `getIconAsBase64` function just uses some built in .Net classes to extract an icon from a path and convert its image data to Base64.

## NodeJS Icon Extractor Object

Now lets look into how we can use this to our advantage on the NodeJS side of things. NodeJS and .NET do things very differently from one another, and a module like this can be a bit daunting at first so we'll break it down bit by bit. Here is the code

```js
var EventEmitter = require('events');
var fs = require('fs');
var child_process = require('child_process');
var _ = require('lodash');
var os = require('os');
var path = require('path');

function IconExtractor(){

  var self = this;
  var iconDataBuffer = "";

  this.emitter = new EventEmitter();
  this.iconProcess = child_process.spawn(getPlatformIconProcess());

  this.getIcon = function(context, path){
    var json = JSON.stringify({context: context, path: path}) + "\n";
    self.iconProcess.stdin.write(json);
  }

  this.iconProcess.stdout.on('data', function(data){

    var str = (new Buffer(data, 'utf8')).toString('utf8');

    iconDataBuffer += str;

    //Bail if we don't have a complete string to parse yet.
    if (!_.endsWith(str, '\n')){
      return;
    }

    //We might get more than one in the return, so we need to split that too.
    _.each(iconDataBuffer.split('\n'), function(buf){

      if(!buf || buf.length == 0){
        return;
      }

      try{
        self.emitter.emit('icon', JSON.parse(buf));
      } catch(ex){
        self.emitter.emit('error', ex);
      }

    });
  });

  this.iconProcess.on('error', function(err){
    self.emitter.emit('error', err.toString());
  });

  this.iconProcess.stderr.on('data', function(err){
    self.emitter.emit('error', err.toString());
  });

  function getPlatformIconProcess(){
    if(os.type() == 'Windows_NT'){
      return path.join(__dirname,'/bin/IconExtractor.exe');
      //Do stuff here to get the icon that doesn't have the shortcut thing on it
    } else {
      throw('This platform (' + os.type() + ') is unsupported =(');
    }
  }

}

module.exports = new IconExtractor();
```

So first we see where I import a bunch of different modules to do things. The only two that are doing the real heavy lifting in our scenario are `EventEmitter` and `child_process`.

`EventEmitter` is a module that lets us emit events. The `IconExtractor` function will use an event emitter to tell us when our icon is ready after we request it.

The `child_process` module will let us open our .Net process and manage information going to and from it.

The first thing we do in our `IconExtractor` function is setup the new emitter, and start up our .Net icon application in it's own process. I plan on making this more cross platform, so the `getPlatformIconProcess` function is in place to allow me to get a different icon extraction program for other platforms later. We also create a buffer string that will be used later to patch pieces of information together.

Next, we create a `getIcon` function. This function generates a request for us and writes it to the .Net process in JSON.

After that, we add an event handler to our .Net process that gets fired when we get new data. The first thing this does is make sure the incoming data is converted from a UTF8 Buffer to an actual string, then we add it to the buffer we defined above.

Using [lodash](https://lodash.com/) I check to make sure that our string ends with a new line character `\n`. If it doesn't, then we wait for the next set of data to come in and append it to what we got last time.

Next, I take our data buffer and split it based on the `\n` and process each separately. The reason I do this is odd. For some reason, the .Net app will sometimes send more than one JSON statement in a single "flush" of the data.

Then we make sure we skip over any empty data. If the data isn't empty, we emit an event called `icon` that contains a javascript object that was once our `IconRequest`.

If any errors occur, those are emitted through the `error` event for the host application to deal with appropriately.

The final function is internal to the module and is called `getPlatformIconProcess`. Like I said before, this function just lets me extract icons easily for different platforms. Right now I'm only using this for Windows, so we just throw an error on other platforms.

## Conclusion
In my previous [post](% post_url 2015-11-13-talking-to-processes-with-node %) I spoke about how using this method for doing platform specific functions was much easier than writing native NodeJS modules in C++. I hope this non-trivial example proves that point and is useful to other people trying to get Windows icons in Node.

As far as speed is concerned, I haven't personally benchmarked anything. The speed of doing this works well enough for my needs at the moment.

I know other solutions for using .Net code in NodeJS exist with projects like [Edge.js](http://tjanczuk.github.io/edge/) but again, if you don't need absolute real-time speed, the complexity level of incorporating .Net code right into your NodeJS application might not be worth it.
