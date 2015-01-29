---
layout: post
title:  "Cordova Getting Started"
date:   2015-01-04 08:40:00
categories: science cordova phonegap code
author: Justin
---

# Cordova Platform

Cordova is a system that allows you to write native mobile applications using HTML, Javascript and CSS. It nicely wraps
a web view control and acts as a server for your page or pages. This allows app creators to develop only a single code
base to make applications for different mobile platforms, instead of having to maintain a code base for each type of
platform.

# Differences Between Cordova and PhoneGap

When starting out there is usually quite a bit of confusion between Cordova and PhoneGap. The hybrid project started as
PhoneGap and after a while Adobe purchased PhoneGap and the open source core was donated to Apache. Now a days, PhoneGap
runs on top of Cordova and offers a build service. This service lets users build iOS apps without having to invest in
the large start up cost of purchasing an Apple machine to get started on their iOS device. The user is still required to
purchase a developer license from Apple regardless of using the service.

So, although Cordova started out as PhoneGap, it can be used independently without the help of PhoneGap at all.

# Setting Up Cordova

To set up Cordova, you first need to install [NodeJS](http://nodejs.org/download/). NodeJS is a javascript interpreter
that lets you run javascript outside of the browser on your server. Cordova is based off NodeJS and all the plugins
built for it are created using NodeJS as well.

You can double check that NodeJS is properly installed by opening up a command prompt and running `node -v`. This should
print out the version of node you've just installed. If you get something like `'node' is not recognized as an internal
or external command, operable program or batch file.` Then that means it either did not install correctly, or get added
to your path correctly. Try re-installing it, or checking your PATH variable.

Once NodeJS is installed, you need to install the Cordova node package. Node uses a package manager called [npm](https://www.npmjs.com/)
which stands for node package manager. Npm comes installed alongside NodeJS so all you need to do to
install the Cordova package is run `npm install -g cordova` in a command prompt. The `-g` tells npm to install the
package globally so you can use the `cordova` command anywhere in a command prompt.

Now it's time to start your first Cordova project. This command creates a directory containing your Cordova project.
Open a command prompt to the directory you want your project directory to be created in and run the command
`cordova create <directory> <project namespace> <project name>` where `<directory>` is the name of the directory you
want to create the project in, `<project namespace>` is the Id of your project and `<project name>` is the name of
your project. The project namespace needs to be in reverse .com notation, for example com.mywebsite.myappname. The
project name is what will show up under the icon in your apps list once you install the app on a device.

Then, your project is setup and ready for editing. All the web based files are under the `www` directory and you'll see
that is is very much like any other normal web application.

As a quick reference, here are the steps to starting a new project:

1. Install node
2. Run `npm install -g cordova`
3. Run `cordova create <directory> <com.namespace.project> <Project Name>`
  * `<directory>` is the directory that will be created for the project
  * `<com.namespace.project>` is the ID of your project in reverse .com notation
  * `<Project Name>` is the name of the project that will show up under the app icon

# Setting up the Android platform

You probably want to get a look at what you've done so far to make sure everything is working. In order to do so you
need to add a platform to your project. Since this is a hybrid framework, you can add many different platforms. In this
post we will be covering Android. If you're interested in iOS as well, you need to add that platform from an Apple
machine that has XCode installed.

There are three things you need to install to add the Android platform to your project:

1. The [Java JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
  * Be sure to get the JDK and _not_ the JRE
2. The [Android SDK](http://developer.android.com/sdk/index.html)
  * You can install the Android Studio or just the bare SDK
3. The [ANT](http://ant.apache.org/bindownload.cgi) build tool

Once those are installed, you will also need to create three environment variables and add a few folders to your PATH.
If they already exist, that is fine, just double check that they are pointing to the right spot.

1. `JAVA_HOME` - Point this to the JDK folder
2. `ANDROID_HOME` - Point this to the Android SDK folder
3. `ANT_HOME` - Point this to the ANT folder

There are a few helpful binaries you'll want available when working with the Android platform. To get these, add the
bin\ directory under your ANT folder, the sdk\tools\ and sdk\platform-tools\ directories under your Android SDK folder
to your path. Setting all these up can be quite annoying, to make sure you've got everything right here are example
values from a Windows machine:

1. `JAVA_HOME` = C:\Program Files\Java\jdk1.8.0_05
2. `ANT_HOME` = C:\Program Files\ANT
3. `ANDROID_HOME` = C:\Program Files\Android

And the PATH includes:

1. C:\Program Files\ANT\Bin
2. C:\Program Files\Android\sdk\tools
3. C:\Program Files\Android\sdk\platform-tools

# Running it

Finally, you will want to see the fruits of your labor which you can do without having to install anything to a device.
Run the `cordova build` command to build the code for your platform. Next, just run the command `cordova serve`.
This will host your project locally on port 8000. To get to it just open a browser to the url
[http://localhost:8000/](http://localhost:8000/) and you should see the Cordova bot on the page.

If you see any error messages along the lines of `ant is not a command` or `cannot find ANDROID_HOME` double check that
you have ANT in your path and your ANDROID_HOME variable is set correctly.

Congratulations! You now have your hybrid mobile app running in a browser!

When you load up the app initially, you're probably wondering why you get a pile of alerts all in a row. This is a side
effect of the cordova.js library. It expects certain things that exist in your device's browser that don't exist in
your normal desktop browser. Here are a couple things you can do to make the cordova.js library only load up on mobile
devices. You may have to restart the cordova server for these changes to take effect.

In your index.html file under the www/ folder, comment out the `<script type="text/javascript" src="cordova.js"></script>`
line and add this:

<script src="https://gist.github.com/jbasinger/35cc88069a077e603640.js?file=cordova.js"></script>

You'll also still need some sort of `onDeviceReady` function, so to support that you can add this snippet to your
index.js files:

<script src="https://gist.github.com/jbasinger/35cc88069a077e603640.js?file=deviceready"></script>

The 'deviceready' document event is fired when Cordova is completely loaded and ready for action. Be sure to listen for
it before doing anything that requires device hardware like the camera or accelerometer.

# Running it on a device

While being able to develop and check your work on your desktop is great, eventually you're going to want to put this on
a phone to make sure everything is lining up properly. Plug your phone into your computer and run the command
`cordova run`. This will build, load and launch the app on your device.

# Hybrid recommendations

One thing to remember when developing for hybrid is that the browsers are not as powerful as PC browsers. Here are a
few recommendations to keep your app blazing fast.

Embed all javascript dependencies, or as many as possible. Phones are not constantly connected to the internet. If your
app relies on a library hosted somewhere in the cloud and can't access it, your app will not run properly.

Use a framework like [Ionic](http://ionicframework.com/) or [AngularJS](https://angularjs.org/). Single Page Applications
(SPAs) make your life so much easier when developing a mobile hybrid application. Javascript can get messy quick and
staying organized is key. SPAs help a lot in this department.

Use CSS animations and transitions where you can. jQuery animations are great, but in the mobile world CSS is just plain
faster. Use CSS to make your app pop and have people believing it's actually native.

Test on multiple devices. This one cannot be stressed enough. Every manufacturer adds their own little quirks to every
part of these machines, including the embedded browser. Your app can and will run differently on every device it's
loaded into. For most people getting your hands on multiple devices can be hard. If you need to unify the browser
experience across devices, check out the [Crosswalk](https://crosswalk-project.org/) project. At the expense of making
the app size larger, Crosswalk embeds it's own browser control so all devices can be on the same playing field.

# Frameworks

There are multiple Single Page Application frameworks available. A few examples are [Ionic](http://ionicframework.com/),
[AngularJS](https://angularjs.org/), [Sencha Touch](http://www.sencha.com/products/touch/) and [jQuery Mobile](http://jquerymobile.com/).

I haven't used Sencha Touch or jQuery Mobile enough to speak to them as frameworks, but I have used Ionic for projects
before and highly recommend it.

Ionic is a framework built on top of AngularJS that adds extremely useful directives and takes care of some sticky things
like the Cordova alert pop ups and adding Crosswalk to your project. It also includes templates to get your project started
quickly. It also includes nice CSS transitions and beautiful controls to make your app look and feel native.


