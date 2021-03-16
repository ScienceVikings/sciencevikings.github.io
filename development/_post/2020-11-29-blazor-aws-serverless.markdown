---
layout: post
title:  "Hosting a Blazor WASM site in AWS Serverless"
date:   2020-11-29 00:00:00
author: Justin
---

## Someone put their MS in my AWS!
Today, we're going to get a WASM version of Blazor up and running as a serverless site in AWS. To do this, we'll be building off of my last post about using [CloudFormation](https://sciencevikinglabs.com/simple-cloud-formation/).
We'll tackle this big task with the following steps:

* Build a CloudFormation stack that will contain:
  - A CodeBuild project
  - A S3 Bucket to hold our static site
  - A CloudFront Distribution to serve up our site from S3
* Create a Blazor - WASM project in Visual Studio
* Create Dockerfile and docker-compose.yml files to build and publish our project in CodeBuild
* A buildspec.yml for CodeBuild to do the work

Lets get to work!

### The Stack
To build the stack, we're going to use AWS CloudFormation. This is their built in Infrastructure as Code service and is extremely powerful, but can get a little lengthy even for smaller stacks of resources. For purposes of brevity, We're going to cheat a little bit and re-use a lot of the Cloud Formation stack components used in my previous [post](https://sciencevikinglabs.com/simple-cloud-formation/). All of the resources we need are the same as regular AWS Serverless site setup.

Lets look at the parameters section, quickly. You'll want to name your project whatever you wish, a point the `ProjectSourceLocation` to your github project.
<script src="https://gist.github.com/jbasinger/2dad92921d7eca4215d9054592bbfb7e.js?file=params.yml"></script>

To build the application, we need a CodeBuild project. CodeBuild is one of the few things in AWS named for what it actually does.
It builds code! We're going to make use of it to run our docker containers that will build our project and "publish" it.
<script src="https://gist.github.com/jbasinger/2dad92921d7eca4215d9054592bbfb7e.js?file=codebuild.yml"></script>

We also need a policy to make sure that our CodeBuild project has access to S3 and CloudFront for any changes it needs to make for the build process. There is a difference between this one and the one in my Simple CloudFormation post. This one adds access to CloudFront invalidations which will help us solve a build issue later on.
<script src="https://gist.github.com/jbasinger/bfdb905e3bdb4bead20e68bc1f0185a7.js?file=codebuildpolicy.yml"></script>

Next, we'll need the main site resources. For this, we'll need the S3 bucket to hold our site and a security policy that will allow our CloudFront resource access to serve up what is inside.
<script src="https://gist.github.com/jbasinger/2dad92921d7eca4215d9054592bbfb7e.js?file=s3.yml"></script>

Now lets take a look at CloudFront itself. CloudFront is technically a Content Delivery Network service used to make accessing your static files ultra fast. Lucky for us, our entire site is considered static! There is a small caveat about CloudFront we'll need to address later when doing builds through CodeBuild but we'll take care of that when we address the buildspec.
The CloudFront and CloudFrontOriginAccessIdentity resources set up the CloudFront requirements with some mostly default parameters and makes sure that only the content of our S3 site can be accessed through it.
<script src="https://gist.github.com/jbasinger/2dad92921d7eca4215d9054592bbfb7e.js?file=cloudfront.yml"></script>

We're going to want to know the auto-generated information from CloudFront to be able to setup invalidations and possibly sub-domains later, so lets output the generated domain name and CloudFront ID.
<script src="https://gist.github.com/jbasinger/2dad92921d7eca4215d9054592bbfb7e.js?file=outputs.yml"></script>

### The Blazor
Here we're going to just make a simple Blazor WASM site. For this we're just going to use the base example project that comes with the project template. We'll elaborate more on adding features in a future post.

Make sure you have the latest [dotnet 5.0 framework](https://dotnet.microsoft.com/download/dotnet/5.0) installed then crack open Visual Studio 2019. 

When you create a new project, you're going to want to make sure you choose the Blazor Template.
<img src="/images/blazor-serverless/create-blazor-app.png"/>

Then, make sure you choose the .NET 5.0 Framework in the drop down near the top and select the Blazor WASM version of the template.
<img src="/images/blazor-serverless/initial-settings.png"/>

Click create and you're done! Now, make sure you have a github or equivalent git repository setup for it and make sure that URL is setup in the params of your CloudFormation stack file. That way CodeBuild will know where to pull the code from for building.

### The Dockerfile
Our Dockerfile will be using the latest dotnet 5.0 SDK image to build our project. We'll simply copy the solution into the container, restore the packages and publish in release mode to a build directory. This directory name is important because we'll be pulling those files out later on to publish them to S3.
<script src="https://gist.github.com/jbasinger/bfdb905e3bdb4bead20e68bc1f0185a7.js?file=dockerfile"></script>

To make our lives a little easier, we can run this docker build through docker-compose. When we use these files in CodeBuild, we'll basically setup the site to publish inside the container and pull those published files out.
<script src="https://gist.github.com/jbasinger/bfdb905e3bdb4bead20e68bc1f0185a7.js?file=docker-compose.yml"></script>

### The Buildspec
Finally, we need to make sure things can actually build in CodeBuild. To do this we're using a buildspec.yml file. The file is going to bring up our Blazor site in a docker container. This will build the project and publish it to a directory. Then we're going to copy those files out into our own directory and sync them with S3. 

Normally from here, you'd be done publishing your site, but CloudFront has different plans. You see, CloudFront does some major caching of files at it's edge locations to keep everything as fast as possible. When we publish our new static site to S3, the old verion is still cached and we need to tell CloudFront to invalidate that cache. This is my we gave CodeBuild invalidation permissions to CloudFront. The final step of our buildspec is to invalidate the site with CloudFront so it will serve up our newest content immediately.
<script src="https://gist.github.com/jbasinger/bfdb905e3bdb4bead20e68bc1f0185a7.js?file=buildspec.yml"></script>

## Conclusion
By now you either have or are ready to run your CloudFormation stack in AWS and commit your code so CodeBuild can kick off! Once the build passes, you can check the outputs of the CloudFormation stack to see what domain CloudFront assigned it, go there and see your new site!

We got a lot done here today. We built a CloudFormation stack that will manage the resources needed to host our WASM site. We made a repository for and started building our Blazor WASM site itself, and we published it to S3 so CloudFront could host it for us. Now when we want to make changes, we can simply do so, commit the code and once the build is finished our changes are up and out for the whole world to see automatically.

I hope this information was helpful in setting up a Blazor WASM site in the AWS Cloud space. The scope of this post was to directly address the CI/CD pipeline aspect of things. In a future post I'll be addressing how to setup Lambdas for use with your Blazor WASM site and how to incorporate those in your build process.