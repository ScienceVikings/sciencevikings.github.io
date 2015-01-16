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

Now it's time to start your first Cordova project.

1. Install node
2. npm install -g cordova
3. cordova create directory ProjectName
4. cordova serve
5. Whats with all the pop ups?!

# Setting it up on an android device

Build off this https://docs.google.com/document/d/1wC4w4g9wZQauYGH9d5hpTGw1vp5-xCezlal-W01cKyo/edit#

1. Java JDK
2. Android SDK
3. ANT
4. cordova run

# Easy Mode Setup

Use vagrant, point to vagrant post and Ionic Box.

# Hybrid recommendations

1. Embed all dependencies, or as many as possible
2. Use AngularJS even if you don't use Ionic
3. Use CSS animations/transitions where you can, they are so much faster

# Frameworks

1. Ionic
2. Sencha
3. jQuery Mobile

