---
layout: post
title:  "Ionic Push Notifications"
date:   2015-07-01 15:30:00
author: Justin
image:
  path: /assets/img/mobile_hybrid/ionic-notifications/header.jpg
---

- Table of Contents
{:toc .large-only}

## Ionic Push Notifications

So you have a sweet [Ionic](http://ionicframework.com/) app ready, but want to
be able to push notifications to your users. The guys over at Drifty feel you
and setup [Ionic Push](http://blog.ionic.io/announcing-ionic-push-alpha/) just
for you!

While the [documentation](http://docs.ionic.io/) is well done, there is a lot
there and personally, I feel like it's out of order. In this article we'll cover
 some steps to get setup quickly for an Android device.

Please note that this article assumes you already have an Ionic application and
testing should be done on a real device. It is possible to test notifications in
a browser with Ionic's develop mode, but that's beyond the scope of this article.

## The Flow
The information flows like this:

Your Server -> Ionic's Server -> GCM (Google) -> Device

Simple, right? Right. Lets go over the setup steps.

## Step 1: Setup Accounts
You'll need both an Ionic account and a Google account to use the push
notifications. They both require a little bit of configuration as well.

### Ionic
First, create an ionic account [here](https://apps.ionic.io/signup).
Once your account is created, go to your Ionic application directory in a
console and type `ionic upload`. This will setup your app with Ionic's server.

This will ask for your new ionic login and push your app to their servers.
You should be able to see your app in the Ionic [dashboard](https://apps.ionic.io/apps)
shortly after.

The app with have an ID and will be needed later.

Click the app name to go into the app and view it's settings. There is a public key
and a private key for your application's push notifications. These will be needed later
 as well.

### Google GCM
Next, log into the [Google Developer's Console](https://console.developers.google.com/).
From the Google Developer's console, click the Create Project button, choose a
name and select Create.

Note the Project ID in the project list. This will be needed later.

Select the project name in the list and then, click the Overview link. Note the
Project Number. This is your GCM_ID and will be needed later.

Next, under APIs & auth, click the APIs link. This will show a list of available
 Google APIs. Choose Cloud Messaging for Android and enable the API.

Then, under APIs & auth, click Credentials and Create new Key under Public
Access API. You'll want to select `Server` as the type of key. Follow the
instructions regarding IP restrictions to your preference and select Create.

Note the API Key that was created. Copy that to your clipboard and go back to
your Ionic app directory and use the command `ionic push --google-api-key api-key`
where `api-key` is the key you just copied to your clipboard.

#### Quick Review
1. Create Ionic account [here](https://apps.ionic.io/signup)
2. `ionic upload` in app directory
  - View app [here](https://apps.ionic.io/apps)
3. Create Google Project [here](https://console.developers.google.com/)
4. APIs & auth -> APIs -> Cloud Messaging for Android -> Enable API
5. APIs & auth -> Credentials -> Create new Key -> Server -> Copy API key
6. `ionic push --google-api-key api-key` in app directory

## Step 2: Your Server
Ionic provides a fairly simple RESTful interface to their push server. You make
a HTTP POST to a specific URL with special headers and JSON as the body of the
request. You also need to set the username of basic authentication to your ionic
private key, and nothing for the password.

The URL you POST to is https://push.ionic.io/api/v1/push

The two headers required are:
- Content-Type: application/json
- X-Ionic-Application-Id: YOUR_APP_ID

Where YOUR_APP_ID is the App ID you get from your Ionic
 [dashboard](https://apps.ionic.io/apps).

You can get your private key from the [dashboard](https://apps.ionic.io/apps) as
well, by selecting the settings of your app and viewing the Secret Key.

The POST body will need to be in JSON format like the following:
```json
{
  "tokens":[
    "b284a6f7545368d2d3f753263e3e2f2b7795be5263ed7c95017f628730edeaad",
    "d609f7cba82fdd0a568d5ada649cddc5ebb65f08e7fc72599d8d47390bfc0f20"
  ],
  "notification":{
    "alert":"Hello World!",
    "android":{
      "collapseKey":"foo",
      "delayWhileIdle":true,
      "timeToLive":300,
      "payload":{
        "$state": "a_ui-router_state",
        "key1":"value",
        "key2":"value"
      }
    }
  }
}
```

The tokens are the device tokens you want to send the notification to. The
`alert` key is what will show up on the notification screen, and the payload
will be accessible from your Ionic application once the user selects the
notification from the drawer.

**Gotcha Alert:** Take special note of the `$state` key. This key is required by
the Ionic push service in the framework. It's value should be a state you setup
using ui-router in your Ionic application. If it is not present, things **will**
 blow up. The application will load this state when the notification is opened.

Here is a sample snippet of Ruby code for pushing a notification:
```ruby
device_token = 'example_token'
ionic_private_key = 'your_ionic_private_key_here'
ionic_app_id = 'your_ionic_app_id_here'

form_data = {
    'tokens' => [device_token],
    'notification' => {
      'alert' => "Hello Push World!",
      'android' => {
        'payload' => {
          'url' => url,
          '$state' => 'home'
        }
      }
    }
  }

  puts form_data.inspect

  uri = URI.parse('https://push.ionic.io/api/v1/push')
  req = Net::HTTP::Post.new(uri.path)
  req.basic_auth ionic_private_key, ''
  req['Content-Type'] = 'application/json'
  req['X-Ionic-Application-Id'] = ionic_app_id
  req.body = form_data.to_json

  puts req.inspect

  resp = Net::HTTP.new(uri.host, uri.port)
  resp.use_ssl = true
  resp.start {|http|
    res = http.request(req)
    puts res.body
  }
```

## Step 3: Your App
The final step is to setup your application to receive the notifications. There
are three different states your app can be in when a notification is received.
Open and in the foreground, open but backgrounded, or completely closed. It's important
to make sure your app reacts appropriately in all three states so your user can
get the best experience out of your hard work.

### Preliminary steps
First you need to install a few extra components in your Ionic app using their
`ionic add` and `ionic plugin` command line functions. From your app's directory
in a terminal run the following commands:

```console
ionic plugin add https://github.com/phonegap-build/PushPlugin.git
ionic add ngCordova
ionic add ionic-service-core
ionic add ionic-service-push
```

This will install the phonegap push notification plugin, Ionic's angular to
cordova plugin framework, and Ionic's core and push services used to make
the rest of this a breeze.

Then, open up your `index.html` page and add the following libraries to your
`<head>` tag:

```html
<!-- ionic/angularjs js -->
<script src="lib/ionic/js/ionic.bundle.js"></script>
<script src="lib/ngCordova/dist/ng-cordova.js"></script>
<script src="lib/ionic-service-core/ionic-core.js"></script>
<script src="lib/ionic-service-push/ionic-push.js"></script>
```

Finally, you need to add those services to where you declare your angularjs
module. It should look something like this:

```js
angular.module('yourTotallyAwesomeApp', [
  'ionic',
  'ngCordova',
  'ionic.service.core',
  'ionic.service.push'
]);
```

Please note that all these examples above were borrowed from
[Ionic's documentation](http://docs.ionic.io/v1.0/docs/push-from-scratch).

#### Quick Review
- `ionic plugin add https://github.com/phonegap-build/PushPlugin.git`
- `ionic add ngCordova`
- `ionic add ionic-service-core`
- `ionic add ionic-service-push`
- Add items to `index.html`
  - `<script src="lib/ionic/js/ionic.bundle.js"></script>`
  - `<script src="lib/ngCordova/dist/ng-cordova.js"></script>`
  - `<script src="lib/ionic-service-core/ionic-core.js"></script>`
  - `<script src="lib/ionic-service-push/ionic-push.js"></script>`
- Add modules to your angular module
  - ngCordova
  - ionic.service.core
  - ionic.service.push

### Handling Push Notifications
There are three things your app needs to handle in regards to notifications.
It needs to identify itself with Ionic's server, handle a callback from Ionic to
get the device token for that device and handle a callback from Ionic to do
something when a notification is received.

#### Identify Your App with Ionic
In a `config` block of your Ionic application, you need to identify your app
with the Ionic servers. You need three things for this. Your Ionic App ID,
your Ionic Public key and your Google GCM ID.

Your Ionic App ID is found on the Ionic [dashboard](https://apps.ionic.io/apps).
Selecing the Ionic App name and going to Settings will show you the Ionic Public
Key. Going to the [Google Developer's Console](https://console.developers.google.com/)
and selecting your project and then clicking the Overview link will give you
your GCM ID. It's the Project Number across the top.

Your `config` block should look something like this:

```js
angular.module('yourTotallyAwesomeApp')
.config(['$ionicAppProvider', function($ionicAppProvider) {

  $ionicAppProvider.identify({
    app_id: 'ionic_app_ID',
    api_key: 'ionic_public_key',
    gcm_id: 'google_project_number'
  });

}]);
```

#### Reacting to Notifications
In a `run` block of your app, you can register with the push service to react
to notifications being selected by users when the app is in various states.

When a notification comes in it can be of type `registered` or `message`. When
the `registered` event comes through, you'll get your device token from the message.
You should send this information to your server however you'd like. You'll use this
token to tell Ionic which device to send the notification to.

When the event is `message` it will contain the payload you set on the server
side when POSTing the notification to Ionic's server.

`$ionicPush.register` is also a promise. In the `then` of that promise, fired upon
push registration completion, you need to identify your user with Ionic's server.
This is pretty straight forward, you just get the user with `$ionicUser.get()`
and if they don't already have a user_id field, add one. This field can be anything
you want. I use the device's uuid in the example below which can be used for
anonymous users with Ionic.

Once you set the user id you call `$ionicUser.identify(user)` to set that user up
with Ionic and you're ready to go!

Here is a snippet of what a push registration would look like:

```js
angular.module('yourTotallyAwesomeApp')
.run(function($ionicPlatform, $ionicPush, $ionicUser) {

  $ionicPlatform.ready(function() {
    //A cheat check to make sure we're on a device
    if(window.plugins){

      $ionicPush.register({
        canRunActionsOnWake: true,
        onNotification: function(notification) {

          if (notification.event){

            if(notification.event == "registered"){
              //Here you'll want to do something with notification.regid
              //It's the deviceToken your server will use to tell Ionic
              //whose device this is.
              console.log(notification.regid);
            }

            if(notification.event == "message"){

              //Yes you need to access payload.payload.
              //I tried changing it to something else server side
              //and it didn't work. Sorry =(
              console.log(notification.payload.payload);

              if(notification.foreground){
                //This state happens when the notification comes in and the user
                //is in the application.
                console.log('Foreground Notification Received!');
              } else {
                if(notification.coldstart){
                  //This state happens when the notification is selected by the
                  //user but the app is not currently running.
                  console.log('User tapped notification while app was closed!');
                } else {
                  //This state happens when the notification is selected by the
                  //user but the app has been backgrounded.
                  console.log('User tapped notification while app was backgrounded!');
                }
              }
            }
          }
        }
      }).then(function(deviceToken) {

        var user = $ionicUser.get();
        if(!user.user_id) {
          user.user_id = device.uuid;
        };

        $ionicUser.identify(user);

      });
    }
  });
});
```

#### Quick Review
- Identify keys and IDs with `$ionicAppProvider.identify` in `config` block
- Register for push notifications with `$ionicPush.register` in `run` block
- Identify user with `$ionicUser` in `then` of `$ionicPush.register` promise.
- Handle notification states in `onNotification` callback of `$ionicPush.register`
function

## Conclusion
There are quite a few pieces to this puzzle, but once you get the idea of how the
data is flowing, it's a bit easier to understand what each of these pieces are doing
and why they are needed. Now, go notify your users!
