---
layout: post
title:  "Cordova Hooks"
date:   2015-10-06 10:40:00
author: Justin
image:
  path: /assets/img/mobile_hybrid/cordova-hooks/header.jpg
---

Cordova is extremely powerful, but it's not always obvious. Hooks are a good example of this.
Hooks let you attach to specific steps in Cordovas processes and run scripts before and after certain things occur.

In this post, we'll go over a simple way to copy a config file before a build is started, and show a message in the
console once the build has completed.

There are two different ways you can create Cordova hooks. You can either simply put a .js file in a subdirectory of
the `hooks` directory Cordova provides, or you can define one in the `config.xml` file. Lets go over the subdirectory
method first, since it's the simplest.

Here is a sample project on [github](https://github.com/ScienceVikings/CordovaHooks) that shows how to copy a config
file before the build starts, and spits out a fun message when the build is complete.

## Hooks Subdirectories

When you build an Ionic or Cordova project using the command line tools, scaffolding comes along with it to aid development.
One of the directories provided is the `hooks` directory. In this there is a README.md file that explains the type of
subdirectories available for hooks.

The directory names match the time you want your hook to run. For example, if I want a script to run after my build is complete,
I would create an `after_build` directory and place a .js file in it.

There are two special things you need to do with your .js file once you add it. First, you need to make sure the first line is
`#!/usr/bin/env node` and you must make sure the file is executable.
On my windows machine, I didn't have to set any files as
executable specifically, so that piece might be a Unix only scenario.

Inside your .js file you can do anything you want. From there, it's just a regular node script so let your imagination go wild.

## Config.xml Hooks

Now lets handle something a little more tricky. Lets make a hook that copies over a config file containing our Ionic environment
settings before our project builds.

First, create a folder under `www` called `config`. Inside that, create three .js files named `dev.js`, `stage.js` and `prod.js`
In each of those files, create an AngularJS constant similar to the following:

```js
angular.module('constants',[])
.constant('ENV',{
  name: 'dev',
  baseUrl: 'http://dev.whatever.com',
  magicKey: '123-456-789',
  someOtherThing: {
    id: 1,
    arrayOfSomeStuff: [1,2,3,4,5]
  }
});
```

We're going to copy one of those files, depending on the passed parameter to the command line, to the file `www/js/config.js`.
To make sure we can use this constant, add `config.js` to your `index.html` file, and in the `controllers.js` file include the
`constants` module in the `starter.controllers` module. Now you can use `ENV` in your controllers and services.

Now, we'll just create a script in our `hooks` base directory, not in any subdirectory, named `updateConfig.js`

Next, we'll open up our `config.xml` file and add the following tag: `<hook type="before_build" src="hooks/updateConfig.js"/>`

That tag should go right before the `<platform>` tag in `config.xml`. The `type` attribute is the type of hook we're setting up.
The values here are the same as any subdirectory you would create under the `hooks` directory. The `src` attribute tells the
system where to find the file to run.

Now, the contents of the file is going to be a bit different than our after build hook. When defining a hook from the `config.xml` file, you're actually exporting a function that Cordova will call.

Cordova will pass a parameter to your function called `context`. This lets you have access to far more properies about your project than you have by just putting a .js file in a subdirectory. Fire off a `console.log(context)` to see the magic happen.

You can pass parameters to your Cordova build command line calls by prefixing them with `--`. For example, in our script, if we wanted to do a production level build, we'd use the command `cordova build android --prod`.

Here is what the `updateConfig.js` file will look like to copy the correct config file.

```js

//Here we're going to copy our config based on our options. Dev by default

// GOTCHAS - This assumes there will be only one -- style option in the command line.
// More code would have to be added to handle more options.
// Perhaps parse them using this: https://github.com/bcoe/yargs

var fs = require('fs');

module.exports = function(context){

  //Uncomment this to see other options the context gives you.
  //console.log(context);

  //This gives us promises!
  var Q = context.requireCordovaModule('q');

  var defer = Q.defer();
  var envSelect = context.cmdLine.split('--');
  var envName = 'dev';

  if(envSelect.length > 1){
    envName = envSelect[1];
  }

  console.log('Loading environment named: ' + envName);

  var projectRoot = context.opts.projectRoot;

  var sourceFile = projectRoot + '/www/config/' + envName + '.js';
  var destFile = projectRoot + '/www/js/config.js';

  var readStream =  fs.createReadStream(sourceFile);
  var writeStream = fs.createWriteStream(destFile);

  readStream.on('error', function(err){
    defer.reject('Could not copy\n'+sourceFile +'\nto\n' + destFile);
  });

  writeStream.on('error', function(err){
    defer.reject('Could not copy\n'+sourceFile +'\nto\n' + destFile);
  });

  writeStream.on('close', function(){
    console.log('Environment ' + envName + ' loaded successfully!');
    defer.resolve();
  });

  readStream.pipe(writeStream);

  return defer.promise;
}
```

As you can see, this is again just a normal node script. We first parse out the parameter we care about, then we grab the file we're looking for and copy it to the destination. We do a bit of error checking on the way.

## Conclusion

So there you have it. You can use this to do great things with your build process. Anything from copying API keys to moving the
freshly built file up to a server for others to pull down and test. And the hooks are everywhere, you can even add hooks from your plugins.
