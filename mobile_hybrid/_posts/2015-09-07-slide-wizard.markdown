---
layout: post
title:  "Creating a Slidebox Wizard with Ionic"
date:   2015-09-07 10:40:00
categories: mobile_hybrid
author: Justin
---

Ionic has an awesome control called the Slide Box. Let's make a wizard out of it.

![A wizard needs a beard](/images/slide-wizard/preview.gif)

I'm also taking this opportunity to show off some of the other form controls Ionic has to offer. You can get all the code at [github](https://github.com/ScienceVikings/SlideWizard).

## Setup

Step one, like usual, is to start a new project.

`ionic start -a "Slide Wizard" -i com.yourawesomeid.slidewizard SlideWizard sidemenu`

You can use any template you're comfortable with, but I like sidemenu because it sets up so much for you immediately, you don't have to think too hard to get started.

Next, I generally gut the `.config` function in `/js/app.js`. Here is what mine came out to be.

<script src="https://gist.github.com/jbasinger/8c56ae6b0b8f60d1c6d2.js?file=app.js"></script>

# The Views

Usually I rename a couple of the template files in `/templates` to be what I'm going to use, and delete the rest.

Now, lets setup the [slide box](http://ionicframework.com/docs/api/directive/ionSlideBox/). The directive is very straight forward. Here is a stripped down version containing a few slides from `wizard.html`. We'll add a bunch more to it later to act like the animation above.

<script src="https://gist.github.com/jbasinger/8c56ae6b0b8f60d1c6d2.js?file=slidebox-init.html"></script>

If you run the code at this point, you'll have a very simple three slide app. The first thing you'll notice is that you have to grab the header to actually slide.

This is because the slide box doesn't take the entire screen. The slides each contain a `<div class="box">` tag. I added a box class to the css that gives each slide a height.

Something large will do fine, just know that you'll be able to scroll it vertically. The footer we'll add later will always be over the content.

If you look closely you can see we set `show-pager="false"` in the `ion-slide-box` tag. The directive comes with it's own pager, but I wanted to make one from scratch so I turned it off.

There are two more things we need on the view before we start hooking all this up to some data. Every wizard needs some validation, and we need our own pager in place.

Here is the snippet I create to add an error message to the top of the page if something goes wrong.

<script src="https://gist.github.com/jbasinger/8c56ae6b0b8f60d1c6d2.js?file=validation-snip.html"></script>

The `ng-show` makes sure it only shows up if there is an actual error message available.

Here we have our footer. It'll contain two buttons and some text telling us where we are in the wizard.

<script src="https://gist.github.com/jbasinger/8c56ae6b0b8f60d1c6d2.js?file=footer-snip.html"></script>

Notice that the `<ion-footer-bar>` tag is outside the `<ion-content>` tag. The lets Ionic set up our view to always be attached to the bottom of the screen.

# The Controller

Now we need a controller. Lets gut the stuff in `/js/controller.js` and make it our own. I start my completely emptying `AppCtrl`. You can probably delete it completely, but I like having a controller around for the side menu just in case.

I'd like to generalize these slides a bit, so I made a Slide object. It's very simple and only contains an isValid function, a list of validators and an error message.

<script src="https://gist.github.com/jbasinger/8c56ae6b0b8f60d1c6d2.js?file=slide-object-snip.js"></script>

Inside our controller function, we need to add a couple modules to use. `$ionicSlideBoxDelegate` and `$timeout`. `$ionicSlideBoxDelegate` lets us control our slide box programmatically, and we need `$timeout` to let Ionic setup it's directives before we latch on and do the fun stuff.

Our `$scope` will contain the functions we need to go back and forth on our slides with the controls, information about which slides exist and the current slide we're on.

We also have a watch on some information the slide box delegate gives us, so we know when we're changing slides.

<script src="https://gist.github.com/jbasinger/8c56ae6b0b8f60d1c6d2.js?file=scope-functions.js"></script>

We initialize our first slide position to -1. This is because the index changes to 0 initially and we don't want to fire our validation on boot up, that's just silly.

So, when a slide changes, we reset any error message we had previously, check if the current slide we're on is valid and then change slides if it is.

If the slide is not valid, we use the slide box delegate to bounce back to where we were and display the error message.

# Putting it all together

So, obviously the snippets we have don't do a lot unless we make a bunch of slides and use their data in the view. Here is the code I used to make five slides that use different Ionic controls and validators.

<script src="https://gist.github.com/jbasinger/8c56ae6b0b8f60d1c6d2.js?file=scope-slides.js"></script>

Here is the final view, with the error message, slides and footer. It even contains a final slide showing all the data collected from the first five slides.

<script src="https://gist.github.com/jbasinger/8c56ae6b0b8f60d1c6d2.js?file=wizard.html"></script>

And there you have it! Run it with `ionic serve` and see the beautiful wizard we've created together.
