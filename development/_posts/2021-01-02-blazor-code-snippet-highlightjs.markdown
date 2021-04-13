---
layout: post
title:  "Blazor Code Snippet Component with Highlight JS"
date:   2021-01-02 00:00:00
author: Justin
image:
  path: /assets/img/development/blazor-code-snippet/header.png
---

## Make a Code Snippet component in Blazor using Highlight JS

Today I want to show you how to sprinkle some javascript in your Blazor components by making a code snippet component using [highlight.js](https://highlightjs.org/).
Highlight.js is a syntax highlighting tool that is available for 191 different languages with 97 different styles. I've used it before with C#
and it works very well and the styles are great and it helps making this component extraordinarily simple.

### Initializing the Javascript

First thing we're going to need to do is setup the Javascript. [Highlight.js](https://highlightjs.org/) Lets you include just the languages you need and for this we're going
to be using C#. Because of how Blazor renders, we're also going to need a function we call in the OnAfterRenderAsync overload of our component. Here is the code with some context
to see where I added the scripts.

```html
<body>
    <app>Loading...</app>

    <div id="blazor-error-ui">
        An unhandled error has occurred.
        <a href="" class="reload">Reload</a>
        <a class="dismiss">🗙</a>
    </div>
    <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/10.4.1/highlight.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/10.4.1/languages/csharp.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/10.4.1/languages/css.min.js"></script>
    <script>
        window.highlightSnippet = function(){
            document.querySelectorAll('pre code').forEach((el)=>{
                hljs.highlightBlock(el);
            });
        }
    </script>
    <script src="_framework/blazor.webassembly.js"></script>
</body>
```

As you can see, I added the [highlight.js](https://highlightjs.org/) script, the C# language file and the CSS needed to put it all together. All the function I created does is
tell [highlight.js](https://highlightjs.org/) to find all the html tags I want to highlight and do it's magic with them.

### The CodeSnippet Component

Now for the easy part, the Blazor component. Here is the code.

```csharp
<pre class="code"><code class="@Language">
@ChildContent
</code></pre>

@code {
    [Inject] private IJSRuntime _js { get; set; }
        
    [Parameter] public RenderFragment ChildContent { get; set; }
    [Parameter] public string Language { get; set; } = "csharp";

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        await _js.InvokeVoidAsync("highlightSnippet");
    }
}
```

After looking at the markup, you can see that things are quite simple. We're using `@Language` as a parameter and defaulting that to `csharp` since that is what I mostly use the component for myself.
The `@childContent` RenderFragment is where the code we put in our snippet component will be placed. The `OnAfterRenderAsync` overload is invoking our javascript function telling [highlight.js](https://highlightjs.org/)
to find our code and highlight it. It is as easy as that!

You can also add a splash of your own CSS to make things a little prettier. Here is an example of how you could use the component, and the result from the page.

```csharp
<CodeSnippet>
public class PersonModel
{
    public int Id { get; set; }
    [Display(Name="First Name")]
    public string Name { get; set; }
    public string City { get; set; }
    public string State { get; set; }
    [BlazinHeaderFormat("{0:C}")]
    public int Salary { get; set; }
    [BlazinHeaderIgnore]
    public string ThisColumnWontEvenShowUp { get; set; }
}
</CodeSnippet>
```

<img src="/assets/img/development/blazor-code-snippet/result.png"/>

### Conclusion

There we have it, a super simple javascript library combined with a super simple Blazor component and you can now place beautiful code snippets all over your project for other people to see.
I hope this helps inspire other component ideas and gives you a hand on getting started with them. Good luck!