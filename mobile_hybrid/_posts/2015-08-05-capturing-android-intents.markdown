---
layout: post
title:  "Capturing Android Intents with Cordova"
date:   2015-08-05 08:40:00
categories: mobile_hybrid
author: Justin
image:
  path: /assets/img/mobile_hybrid/android-intents/header.jpg
---

- Table of Contents
{:toc .large-only}

## Capturing Android Intents with Cordova

I'm working on an Android app using Ionic that sends URLs from your PC to your device, and visa versa with a single click/tap.
I figured an easy way to send the URL from the device to the PC would be to use the built in Share capabilities that Android provides.
Unfortunately, this is not baked into the Cordova or the Ionic frameworks. Luckly, I found a [plugin](https://github.com/Initsogar/cordova-webintent) that can
help with this.

In this post we'll be using the WebIntent Android Plugin to allow other apps on our device to share information with our app.

To install this plugin, run the following command in a command prompt from within your app: `cordova plugin add https://github.com/Initsogar/cordova-webintent.git`

# Android Intents and Filters
The way Android sends information between apps on a device is using a concept called Intents. Without going heavy into the details, an Intent is a message
that is either pointed to a specific app, or to any app that can do something with the data being passed.

To tell the Android system that you can handle a specific type of data, you use what is called a Filter. In your Android Manifest you setup your filter with
a specific MIME type to tell the system you can handle that data.

For example, if you wanted to capture Intents containing image data, you would setup a filter
using the MIME type `image/*` and then your app will show up in the Share menu of all
 the apps capable of sharing images.
See the [documentation](http://developer.android.com/guide/components/intents-filters.html) for more information.

# Capturing Text Intents
First off, we're going to need to implement a filter that lets the Android system know
we're super serious about text data. Unfortunately there isn't a very clean way to
update your AndroidManifest.xml file from within Cordova or Ionic so we'll be
manually editing this.

Please note that if you remove, and the re-add the Android platform you'll have to recreate any changes to the manifest file.

Below is a snippet of what I added to the manifest file, and the completed file.

```xml
<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="text/plain" />
</intent-filter>
```

```xml
<?xml version='1.0' encoding='utf-8'?>
<manifest android:hardwareAccelerated="true" android:versionCode="1" android:versionName="0.0.1" package="com.sciencevikinglabs.bestintentions" xmlns:android="http://schemas.android.com/apk/res/android">
    <supports-screens android:anyDensity="true" android:largeScreens="true" android:normalScreens="true" android:resizeable="true" android:smallScreens="true" android:xlargeScreens="true" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <application android:hardwareAccelerated="true" android:icon="@drawable/icon" android:label="@string/app_name" android:supportsRtl="true">
        <activity android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale" android:label="@string/activity_name" android:launchMode="singleTop" android:name="MainActivity" android:theme="@android:style/Theme.Black.NoTitleBar" android:windowSoftInputMode="adjustResize">
            <intent-filter android:label="@string/launcher_name">
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
            <intent-filter>
                <action android:name="android.intent.action.SEND" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="text/plain" />
            </intent-filter>
        </activity>
    </application>
    <uses-sdk android:minSdkVersion="16" android:targetSdkVersion="22" />
</manifest>
```

Within the snippet, you see the multiple tags `<intent-filter>`. You don't really need to make a separate tag for each intent filter unless you're handling specific things with different MIME types. I like to keep them separated regardless for general cleanliness.

The first intent filter tells the system which activity to launch when the user opens the application, and also that the app should show up in the launcher.

The second intent filter is the one I've added. Here we're telling the system that we can handle "SEND" actions that are made up of plain text.

# The Ionic Side of things
Now that our OS knows we care about text data, we can get it from our plugin. In a `run` function of your Ionic app, we'll add the following code to check if we have incoming text data and determine what to do with it.

```js
angular.module('starter', ['ionic', 'starter.controllers'])

.run(function($ionicPlatform) {
  $ionicPlatform.ready(function() {
    if (window.plugins){
      window.plugins.webintent.hasExtra(window.plugins.webintent.EXTRA_TEXT,
      function(hasIt){
        if (hasIt) {
          window.plugins.webintent.getExtra(window.plugins.webintent.EXTRA_TEXT,
          function(textData){
            console.log(textData);
          }, function(err){
            console.log(err);
          });
        }
      },function(err){
          console.log(err);
      });
    }
  });

});
```

Looking more closely at the code, you can see that we're using the `hasExtra` function to check if there is incoming text data from an outside application, then use `getExtra` to pull the actual data. If you don't check that data is there first, a funky error comes up that is more annoying than harmful.

Both of those functions require a constant, `window.plugins.webintent.EXTRA_TEXT`. This tells the system that we only care about text data in the extra field. Then both the functions take two call backs, a success and error callback function.

Please check out [my github page](https://github.com/jbasinger/BestIntentions) to see a sample application using the webintent plugin.

## Gotchas
There were a couple of gotchas that threw me for a loop when creating the sample application for this. The first was `$ionicPlatform.ready()`. If you don't put the code to use the plugin inside the callback for `$ionicPlatform.ready()` then the plugins most definitely won't be ready, and your checks will never be called.

The second was any other type of intent data besides text. Theoretically you can get image data from this plugin as well, but I wasn't able to do it. Looking into the source code it looks like you can get some URI values for certain files to open them, but the code would have to be changed to be able to capture the straight data.

The third was timing of the `getExtra` function being called. It always happened after the initial page loaded so I resorted to calling `$rootScope.$broadcast()` to notify my controllers when that data was available.

# Conclusion
All things considered, this is a generally useful cordova plugin. I would like to see a function along the lines of `getExtraData` that returned base64 encoded data so we could capture more information from other apps easily, but what it provides now is certainly adequate.
