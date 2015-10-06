---
layout: post
title:  "Writing Ionic Plugins with Android"
date:   2015-08-15 19:40:00
categories: science ionic cordova plugin mobile hybrid
author: Justin
---

Sometimes Cordova just doesn't have access to some libraries you'd have access to if you were writing a native application. Maybe you need to do some heavy processing, but don't want to bog down the thread that the Web View runs on. Perhaps there is a third party library you'd love to use, but there isn't a Javascript interface to it.

This is where plugins come in. Plugins are a way to interface native code with your hybrid solution, and today we'll talk about how to make our own.

Here is a [github project](https://github.com/jbasinger/ReversePlugin) containing the working examples in this post.

## Required Items

You need three things to make a Cordova Plugin:

1. A plugin.xml file
2. A Java class extending the `CordovaPlugin` class that overrides the `execute` method
3. A Javascript file that calls your Java class using the `cordova.exec` function

In this post we'll create the ReversePlugin. This magical plugin will take a string, reverse it using Java and give it back to us. We'll go over each piece and explain how to set things up and various caveats to watch out for in each step.

## Plugin.xml

First, create a directory to house all your files. You'll need everything packaged in a directory any way to install the plugin and test it out. In that directory, create a `plugin.xml` file.

Here is our example plugin.xml, we'll go over the included tags.

<script src="https://gist.github.com/jbasinger/38e67ecc3d77be86b77e.js?file=plugin.xml"></script>

The root tag is the `<plugin>` tag. This includes the XML Namespace (`xmlns`) an id and a version attribute. The id and version attributes are what show up when you call `ionic plugin ls` in your normal Ionic applications. This tag houses the rest of our tags.

The next few tags are used for various plugin management systems, for example [plugman](http://plugins.cordova.io/#/). These tags are `<name>` `<description>` `<license>` and `<keywords>`.

After that we start to get into the meat of things. The `<js-module>` lets us declare where our Javascript interface file lives, and where it will exist in the global namespace of our application. The `src` attribute of this tag allows us to tell the plugin where our source file is for the Javascript interface.

Inside the `<js-module>` tag we see the `<clobbers>` tag. The `target` attribute in this tag tells the system which variable our interface will take over in the application. In our example, we'll have an instance of the Reverse object in the `window.reverse` property, and it will be available globally.

Finally, we get to the `<platform>` tag. Within this tag, you define the specifics for the native platform your plugin supports. By looking at the `name` attribute, you can see we're only supporting the Android platform for this plugin. If we were to support another platform, it would have its own `<platform>` tag.

The guts of our `<platform>` tag is very Android specific. The first tag underneath `<platform>` is the `<config-file>` tag. This is a very important tag as it lets you modify the configuration file of your Ionic application when the plugin is installed or updated.

The `target` attribute tells the system which file we're going to modify, and the `parent` attribute sets which XML node we're going to modify. In the case of our example, we're after `config.xml` in our application and the root node.

The `<feature>` tag inside the `<config-file>` tag is the XML we're going to place in the `config.xml` file. The `name` attribute of the `<feature>` tag is *extremely* important, as it is the name you'll use for the `service` parameter when calling `cordova.exec` in the Javascript interface file.

The `<param>` tag inside the `<feature>` tag explains that our feature is an android package, and the `value` attribute is the full namespace, including class name, of our Java class.

Outside the `<feature>` tag but still within the `<platform>` tag we have the `<source-file>` tag. This tag tells the system where our Java source file exists, and the location it should be put in when compiling our APK. This should be in a reverse domain notation folder structure like all normal Java files.

# Java Implementation

Step two in the process is building the Java side of the plugin that will handle the native code we care about. Here is the Java file for reversing the string.

<script src="https://gist.github.com/jbasinger/38e67ecc3d77be86b77e.js?file=ReversePlugin.java"></script>

Lets start with the very first line. `package com.sciencevikinglabs.reverseplugin;` is setting the namespace of our file. This, along with the name of our class is used in the `value` attribute of the `<param>` tag inside the `<feature>` tag of our `plugin.xml` file.

Next, check out the libraries we are importing. The Cordova libraries are needed to interface between the native code and Cordova's Javascript. The JSON libraries are useful for converting the data you need to send back to the Javascript side into a readable format. If you were writing and wrapper for a 3rd party Java library, you'd import the files you need here as well.

After the imports we see the class declaration. You can name your class whatever you want, but it must extend `CordovaPlugin` or it won't be picked up by the system.

Inside the class we see a standard Java constructor, then an `initialize` function. This function is fired right before the plugin comes into use for the first time. If you want this function to be fired immediately as your application starts loading, add `<param name="onload" value="true"/>` to the `<feature>` tag of your `plugin.xml` file.

The final function we see is the `execute` function. This function is responsible for responding to the `cordova.exec` function call we'll see in the Javascript interface. It lets The `action` parameter is the action taken by the user, and `args` is an array of arguments passed to the action.

This function should do whatever the action is responsible for, call the `callbackContext.success` function, passing it whatever data the Javascript side needs in JSON or primitive formats then return `true` to tell Cordova that everything worked.

If an error occurs, you can call the `callbackContext.error` function with a `JSONObject`, `String` or `int` parameter to tell the Javascript side what went wrong, then you should return `false` so that Cordova knows there was an issue with that action.

# Javascript Implementation

The final piece of the puzzle is the Javascript interface to the Java plugin. This is actually a node.js type of Javascript file that exports the object that will be put in the spot you defined in the `clobbers` tag of your `plugin.xml` file.

<script src="https://gist.github.com/jbasinger/38e67ecc3d77be86b77e.js?file=reverse.js"></script>

The first thing we do is `require('cordova')`. This lets us fire the `exec` function that will find our Java code and run it for us.

Next we create a Reverse class that will basically be a wrapper for the `exec` call. As you can see from the above example, we created a terrible function name and used it to fire `cordova.exec`.

There are a couple gotchas regarding the `cordova.exec` call that I have noticed. The first is that if you don't pass some kind of function to the success *and* failed callback parameters, the call just silently fails. That is the reason for checking if those callbacks are null and replacing them with a blank function if they are.

The second gotcha has to do with the third parameter passed to `cordova.exec`. The string you pass here has to be the same string as the `name` attribute of the `<feature>` tag inside your `plugin.xml` file.

Now, the fourth parameter is the action that will be passed as the action string in the Java class. The final parameter has to be an array. This array will be passed as the args JSONArray parameter in the Java class. Use those parameters to pass data into the plugin as needed.

# Conclusion

As you can see, writing a plugin can require a few steps and the ride can be very bumpy if you don't get your configuration just right. I would recommend that you write a Java class outside of the plugin to use inside the plugin as simply as possible so it can be nicely isolated and unit tested. This will make the native code side of the issue much easier.

Also, try to name everything the same. That way you don't have to remember if you pluralized something, or added some silly prefix or suffix in one spot, but not the other and it results in a broken plugin.

Another useful function the plugin architecture provides is hooks. Hooks let you run a script at specific points of the install, prepare or build processes. There is a bit to go over there so we'll cover it in another post.

Although there are a few things that can be done to make the plugin writing process simpler, it's a very powerful tool that lets you interact with native code and Cordova did a fine job in implementing such a useful feature.
