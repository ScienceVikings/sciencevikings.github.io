---
layout: post
title:  "Blazor Code Snippet Component with Highlight JS"
date:   2021-01-02 00:00:00
categories: "Blazor JSInterop components highlight js"
author: Justin
---

## Make a Code Snippet component in Blazor using Highlight JS

Today I want to show you how to sprinkle some javascript in your Blazor components by making a code snippet component using [highlight.js](https://highlightjs.org/).
Highlight.js is a syntax highlighting tool that is available for 191 different languages with 97 different styles. I've used it before with C#
and it works very well and the styles are great and it helps making this component extraordinarily simple.

### Initializing the Javascript

First thing we're going to need to do is setup the Javascript. [Highlight.js](https://highlightjs.org/) Lets you include just the languages you need and for this we're going
to be using C#. Because of how Blazor renders, we're also going to need a function we call in the OnAfterRenderAsync overload of our component. Here is the code with some context
to see where I added the scripts.

<script src="https://gist.github.com/jbasinger/991ea0d63661430fe94cd293055001f9.js?file=index.html"></script>

As you can see, I added the [highlight.js](https://highlightjs.org/) script, the C# language file and the CSS needed to put it all together. All the function I created does is
tell [highlight.js](https://highlightjs.org/) to find all the html tags I want to highlight and do it's magic with them.

### The CodeSnippet Component

Now for the easy part, the Blazor component. Here is the code.

<script src="https://gist.github.com/jbasinger/991ea0d63661430fe94cd293055001f9.js?file=CodeSnippet.razor"></script>

After looking at the markup, you can see that things are quite simple. We're using `@Language` as a parameter and defaulting that to `csharp` since that is what I mostly use the component for myself.
The `@childContent` RenderFragment is where the code we put in our snippet component will be placed. The `OnAfterRenderAsync` overload is invoking our javascript function telling [highlight.js](https://highlightjs.org/)
to find our code and highlight it. It is as easy as that!

You can also add a splash of your own CSS to make things a little prettier. Here is an example of how you could use the component, and the result from the page.

<script src="https://gist.github.com/jbasinger/991ea0d63661430fe94cd293055001f9.js?file=usage.razor"></script>

<img src="/images/blazor-code-snippet/result.png"/>

### Conclusion

There we have it, a super simple javascript library combined with a super simple Blazor component and you can now place beautiful code snippets all over your project for other people to see.
I hope this helps inspire other component ideas and gives you a hand on getting started with them. Good luck!