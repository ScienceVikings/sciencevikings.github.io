---
layout: post
title:  "Remote Control Firefox"
date:   2015-10-28 10:40:00
author: Justin
image:
  path: /assets/img/development/remote-control-firefox/header.png
---

Have you ever thought it would be neat to be able to control your browser
from another application? Me too. In fact, I think we should be able to
control all our applications from other applications.

In this post I'm going to go over a hodge podge of pieces I put together
to be able to play and pause YouTube videos in Firefox by just making
an HTTP POST request.

## The Plan
So here is a run down of the plan to make this happen. First, create
a Firefox plugin. Have the plugin look at all the tabs being opened.
If a tab is a YouTube tab, add it to a list.

Next, we'll create a page-mod for our YouTube pages. A page-mod is a
script that gets added to a page from your plugin. We're going to use it
to fire functions that find the video tag on the page and pause or play them.

Now we need a way to control it. To accomplish this we'll need two components.
A client and a server. Our server will be a Ruby Sinatra application. It's sole
purpose in life is to be a queue.

The server will just take HTTP POST requests with a `cmd` parameter in the form
data and put them in a queue. When an HTTP GET is requested on that queue, the
server will pop the `cmd` and return it.

The client will be a page-worker. This is a hidden page for your plugin that just
runs Javascript and can have some HTML as well. All this will do is loop every
500ms and fire an HTTP GET request to our server. This is actually a perfect
job for WebSockets, but I wanted to prove I could do this before getting fancy.

If there is nothing in the queue, the response from the server will just be null.
If there is a command, we'll send it from our page-worker to our main plugin which
will in turn loop through all our YouTube tabs, and call the appropriate function
we added to it with our page-mod.

Clear as mud, right? Ok, good! Lets look at the parts individually.

## The Firefox Plugin
Making a Firefox plugin is an interesting concept that definitely warrants its own
blog post. Here we're just going to go over the quick and dirty getting started concepts.

First, make sure you have [node.js](https://nodejs.org/en/) installed and crack open a
command prompt. In the prompt run `npm install -g jpm`. Use sudo if you're a Mac user
or Unix wizard. This installs the Firefox plugin toolkit.

From there, check out Mozilla's great [Getting Started](https://developer.mozilla.org/en-US/Add-ons/SDK/Tutorials/Getting_Started_%28jpm%29) page regarding the creation of a plugin. Use it to start your own.

Once you've created your plugin skeleton, open up the `index.js` file. This is the file
that your plugin starts from. The entire plugin is just Javascript! Remember, our first
task is to peek at the tabs as they are opened, check their URL for YouTube, add some
magic script to it and push that tab into a list.

Below is the code for getting a sneak peak at those tabs and injecting some scripts into them.

```js
var self = require('sdk/self');
var tabs = require("sdk/tabs");
var URL = require("sdk/url").URL;

var youtubeTabs = [];

tabs.on('ready', function(tab){

  if(URL(tab.url).host == 'www.youtube.com'){

    var worker = tab.attach({
      contentScriptFile: self.data.url('youtube.js')
    });

    var obj = {'tab': tab, 'worker': worker};
    youtubeTabs.push(obj);

  }
});
```

In the first few lines of code you can see us pulling in some plugin SDK elements. The
`self` var lets us get access to other files in our plugin.

The `tabs` var lets us control the tabs within Firefox, and the `URL` var lets us do some
work with URLs that would otherwise be tedious and annoying.

Next we setup an array to hold our YouTube tabs. Then, using the `tabs.on('ready')` event
we watch for new tabs that are ready to rock. Once they are, we use `URL` to check if they
are YouTube tabs. If it's not a YouTube tab, we don't really care and move on.

If it is a YouTube tab, we attach a script to it, make a small object that keeps track of
the tab and the script, then stuff it into our array for later use.

You can see the `self` var in use when we attach the script file to the tab. `self.data.url` lets us find the "url" of a file in our data directory.

## The Page-Mod
So, what exactly is that `youtube.js` file that we're attaching to our YouTube tabs? Well,
first off it's in a directory named `data` in our plugin skeleton. This folder might not
exist and you may have to create it.

This file is code that will be injected into our tabs for immediate or later use. We're
going to setup a `port` between our `index.js` file and our YouTube tabs. Here is the code
below.

```js
self.port.on('pause',function(sup){
  var vid = document.getElementsByTagName("video")[0];
  vid.pause();
});

self.port.on('play', function(){
  var vid = document.getElementsByTagName("video")[0];
  vid.play();
});

self.port.on('toggle', function(){Here we
  var vid = document.getElementsByTagName("video")[0];
  if(vid.paused){
    vid.play();
  } else {
    vid.pause();
  }
});
```

We have access to the `self` object in our injected file, and the `port` property lets us
respond to and emit messages between files. So, any time we call `self.port.emit('play')`
in our main file, it'll fire that function in this file.

I've created three messages the YouTube tab can respond to. In the toggle function you can
see that we're just finding the video tag and using normal HTML5 functions to play or
pause the video depending on it's current state.

## The Server
Now onto our server, which is just an over-engineered queue. This part is built with Ruby
using Sinatra. It's also setup to handle multiple queues, but we're just taking advantage
of one for now. I have bigger plans for this beast eventually.

Lets just jump right into the code.

```ruby
require 'sinatra'
require 'json'

set :queues, {}

before do
  build_cors_headers
end

post '/queue/:qName' do |qName|

  halt 400, 'Use the "cmd" key' unless params["cmd"]

  q = get_queue(qName)

  q << params["cmd"];

end

get '/queue/:qName' do |qName|

  q = get_queue(qName)

  if q.empty? then
    nil.to_json
  else
    q.pop.to_json
  end

end

options '*' do
  200
end

def build_cors_headers
  response.headers['Allow'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
  response.headers['Access-Control-Allow-Methods'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS' #['HEAD','GET','PUT','POST','DELETE','OPTIONS']
  response.headers['Access-Control-Allow-Origin'] = '*'
  response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
end

def ensure_queue(qName)
  settings.queues[qName] = Queue.new unless settings.queues.has_key?(qName)
end

def get_queue(qName)
  ensure_queue(qName)
  settings.queues[qName]
end
```

This looks like a lot, but it's pretty straight forward. First we bring in our Sinatra and
JSON gems. Then we set a Sinatra setting `:queues` to be a hash. This will house our
queues. Everything is done in memory, as it's all meant to be fast paced and short lived
anyway.

Next you'll see the `before` call. This fires before every single request. In it we
setup CORS which stands for Cross-Origin Resource Sharing. If you want to get into the
specifics of it, ask Ryan. Here is the web dev run down, you need to just add a
bunch of headers and return 200 on the OPTIONS method for requests.

If you don't do this, your plugin, which runs on a different port, can't connect to
your server, because it's only expecting requests from the same domain. The port, in this
case, is considered part of that domain.

Now, on to the `post '/queue/:qName'` block. Here, we check if the key "cmd" was passed
in the data. If it wasn't we toss a `BAD REQUEST` error and halt everything.

If we have a command, we get our queue by whatever name was passed and stuff the command
string right in there. The `get_queue` and `ensure_queue` functions are just to reduce
some clutter. They make sure the queue we're looking for exists, and if it doesn't it
creates it.

The `get '/queue/:qName'` block is even more simple. Get the requested queue from our
hash and if it's empty return null as JSON. If it's not, pop the command off the queue
and return it as JSON. The `pop` function is an alias for `deq` so don't worry, this is a
FIFO queue.

## The Page-Worker
The final connection will be made using a page worker. The page worker is a hidden page
you can create using your plugin to do work for you. Here is the code used to create
a worker page.

```js
var pageWorkers = require("sdk/page-worker");

pageWorker = pageWorkers.Page({
  contentURL: self.data.url("worker.html"),
  contentScriptFile: [self.data.url('jquery-2.1.4.min.js'),self.data.url('worker.js')],
  contentScriptWhen: "ready"
});

pageWorker.port.on('command', function(cmd){

  switch(cmd){
    case "toggle youtube":
      sendYoutubeCommand('toggle');
      break;
    case "play youtube":
      sendYoutubeCommand('play');
      break;
    case "pause youtube":
      sendYoutubeCommand('pause');
      break;
    default:
      break;
  }

});

function sendYoutubeCommand(cmd){
  for(var i=0; i< youtubeTabs.length; i++){
    var yt = youtubeTabs[i];
    yt.worker.port.emit(cmd, 'cmd');
  }
}
```

First, we need to pull in the page worker sdk, then we create a page by calling  
`pageWorkers.Page` and pass it some options.

The `contentURL` is an HTML page to go along with your script. I just put a `<div></div>`
tag in my `data/worker.html` file for this.

For the `contentScriptFile` option, we provide an array of scripts to inject. The first
file is a copy of jQuery, so we can use it's `$.ajax()` function. The second is the script
that does the actual work, which we'll get to in a moment.

The `contentScriptWhen` option tells the system when to fire your scripts you've injected.
Here we've used the "ready" option, so when the page worker is ready, it'll run.

Next we see the `pageWorker.port.on('command')` function being setup. Once our main script
receives a "command" from our worker, it'll loop through our YouTube tabs we stored
earlier and pass the appropriate command along to them.

Lets look at the `worker.js` page to see how we're connecting to the server.

{% gist 2189ac829bfdad67b547 worker.js %}

This is actually a very good use case for web sockets, but since this was just a proof of
concept for me, I decided to keep it simple and just poll the server every 500ms.

In each poll, we look for commands on the `firefox` queue name and emit a command backend
to our main file. It doesn't get much easier than that.

## How to make sure it works?
This is all fine and dandy, but how do you make sure any of it actually works? Well, first
make sure your Sinatra app is running. Then in your command prompt under your plugin
directory, kick off `jpm run`. This will open up a new instance of Firefox with your
plugin installed and isolated for testing.

Next, you can open up your favorite motivational YouTube
[clip](https://www.youtube.com/watch?v=ZXsQAXx_ao0) and fire a POST command to your
server! Remember, nothing is impossible. Don't let your dreams be dreams.

There are about a billion ways you can POST data to your server, but I prefer to use
another plugin called [REST Easy](https://addons.mozilla.org/en-US/firefox/addon/rest-easy/). You can set it up to
fire any HTTP method you need with any data you wish. It's very useful.

## Conclusion
There are a lot of pieces to this puzzle, but they all come together quite simply and in
a very useful bit of functionality. I plan to eventually flush this out with other
commands and set it up to use web sockets instead of polling.

A tool like this could be used to allow other applications to manipulate Firefox from a
distance dynamically. It's not like Selenium or other web drivers, where you script what
you want to do ahead of time.

I hope this idea helps to inspire other things that can be remote controlled, or fun ways
to use this functionality to increase productivity.
