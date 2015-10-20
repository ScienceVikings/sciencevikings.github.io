---
layout: post
title:  "Setting Up Karma for Ionic"
date:   2015-10-06 10:40:00
categories: ionic karma unit-testing
author: Justin
---

Unit testing! The wonderful thing everyone wants to do but never does.
In this post I'll show you how to do it so you don't have an excuse not to.

Now, I'm not going to go in depth about unit testing, behaviour driven development (BDD),
or test driven development (TDD) and it's endless helpfulness, especially in javascript.
I'm still green myself in the realm of it all and it is a very in depth topic with lots
of arguments on how to do it.

I'm going to just show you how to use a library called [Jasmine](http://jasmine.github.io/)
and a great tool called [Karma](http://karma-runner.github.io/0.13/intro/installation.html)
to setup your testing environment for your Ionic apps.

## Install
The first thing to do is to install the karma command line tool. You can install it like a
regular module, but it's annoying to have to run it from the node_modules path. Run the
following in your command line:

`npm install -g karma-cli`

Now we need to setup Karma for Jasmine, and make it so it runs the tests in a brower.
I'm going to choose Chrome as the browser. You'll need whatever browser you choose installed.
You can install them both at the same time and save them in your package.json file with this:

`npm install karma-jasmine karma-chrome-launcher --save-dev`

The `--save-dev` option is what puts it under the dev environment in our package.json file.

## Configuring Karma
The next step is to configure Karma. Karma uses [Node.js](https://nodejs.org/en/) so it's configuration
is simply a script that exports a function. It also provides a simple way to initialize a config file.
Create a `tests` directory, go into it with your command line and run this command:

`karma init config.karma.js`

The argument `config.karma.js` is the name of the file it will create. You can name the file whatever you'd like. It asks you a bunch of questions to initialize the file. Anything you choose is changable after the fact
so don't worry too much about the details.

The most important part of the file is the `files` list. Here is a glob syntax list of files to load up for testing.

You need to include everything here. Ionic, angular-mocks, your app's files and your test files. I usually name
my tests `*.spec.js` so I can tell they are tests right off the bat.

A note on angular-mocks. This is an angular package that doesn't come bundled with Ionic. You can install it with bower like so:

`bower install angular-mocks`

Angular-mocks is a bunch of mocking classes for angular to test things like the `$http` service and setup
angular itself to be run in a testing setting. A must have for angular unit testing.

Here is an example of my `files` field in my configuration file.

<script src="https://gist.github.com/jbasinger/877d3608d4dd37fa1b0b.js?file=files.js"></script>

# Running the tests
This part is the easiest part. Since you're in the directory of your config file just fire off the following command:

`karma start config.karma.js`

This kicks off Karma, opens a browser and runs through all your unit tests. The best part is that if you have `singleRun: false` and `autoWatch: true` set in your config, it'll watch all the files you gave it, and once you save any of them, it'll run the tests again alerting you of failures.

# Jasmine
Jasmine is a tool that lets you write your unit tests descriptively. You use `describe` functions
to organize your tests, and `it` functions to explain what it should be doing.

It's best to decribe with an example. Here is a Pizza class I made to show a trivial unit test:

<script src="https://gist.github.com/jbasinger/877d3608d4dd37fa1b0b.js?file=pizza.js"></script>

Simple right? A default pizza comes in 8 slices, but you can override the number you want.
Now here are the tests showing how to make sure this class functions like we want.

<script src="https://gist.github.com/jbasinger/877d3608d4dd37fa1b0b.js?file=pizzaTest.js"></script>

Pretty simple stuff. Unfortunately, the real world isn't as simple and I don't want to leave you with
a trivial example and send you off to unit test something like a web service call.

Lets assume we want to order the new pizza we just made over the internet, because the future is now.
Here is the pizza service I created to do just that:

<script src="https://gist.github.com/jbasinger/877d3608d4dd37fa1b0b.js?file=pizzaService.js"></script>

A very simple service that just has an orderPizza function that fires a POST to '/order'. Testing it on
the other hand is a little more difficult. First I'll show you the example, and then I'll explain it.

<script src="https://gist.github.com/jbasinger/877d3608d4dd37fa1b0b.js?file=pizzaServiceTest.js"></script>

First I create a couple variables to hold the services I'll inject using angular. Then you'll notice the `beforeEach` function. This function, as you can probably guess, gets fired before each test is called. We use it to setup our variables.

In the `beforeEach` I call `module('starter.services')`. This initializes the angular module you're testing.
Next I call the `inject` function and pass it the `$injector`. That lets you pull controllers, services and any providers you need from angular for use in your tests. Using the `$injector` I get my `Pizza` service and `$httpBackend` which is a mock for helping us test web stuff.

Now we start setting up `$httpBackend`. We do two things with the backend. We `expect` things and respond to things with `when`. In the inject call you can see the `whenPOST` function. This is saying, when the normal `$http` POSTs data to `'/order'` respond with a 200 status code and `true` for the data.

But putting the return value of that `whenPOST` call in a variable, we can alter the response for specific tests later, without having to setup everything from scratch again in the test itself.

Next we have our `it` statements. The first one just makes sure our function is defined. The next one uses
`$httpBackend` to expect a POST call, then fires our orderPizza function. Our function returns a promise so
we can use the `then()` function on it, and make our order comes through as complete.

Because we setup a `whenPOST` we should get true data and a 200 status call. The pretend call doesn't fire
itself unfortunately. We need to call `$httpBackend.flush()` to run through the motions. Once that is complete we can check our data to make sure our resulting `then` function is called.

It's working! Great! Now we should make sure that we can handle errors. We'll add another expectation of
a POST call. After that you can see we us our `orderHandler` variable to alter our `whenPOST` to respond
with a 500 call instead of the 200. This is a server error result and causes our `catch` function to be
called from our service.

We go through the same motions, but use `catch` instead of `then` to make sure we got the error, and
flush our backend.

## Conclusion

Trivial examples of test cases are very simple. But if you compare the amount of code in the `Pizza` service
to the amount of code in the unit tests, you can see there is a lot involved. Keeping your tests simple,
focused, and generic, you can keep the amount of code down and the need to update and maintain the tests
small.

It seems like a lot of work, but it's value is there. Being confident in your code is one thing, but being able to prove the confidence in your code is worth much more. It takes some getting used to, but TDD will
help you write cleaner, and more confident code.
