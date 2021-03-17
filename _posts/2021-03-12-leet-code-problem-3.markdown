---
layout: post
title:  "LeetCode Problem 3 - Longest Substring Without Repeating Characters"
date:   2021-03-12 00:00:00
categories: "leetcode testing"
author: Justin
---

## LeetCode Problem 3 - Longest Substring Without Repeating Characters

In this post we'll be talking about solving the third [LeetCode](https://leetcode.com/problems/longest-substring-without-repeating-characters/) problem. You can find my code for all my LeetCode submissions at [GitHub](https://github.com/jbasinger/LeetCode).

[LeetCode](https://leetcode.com/) is a site that provides programming problems for practice. A lot of developers use it to hone their skills or to practice for upcoming interviews.
The questions available are used by large tech companies as interview questions, so it's a good place to start and the difficulty of the questions being Easy, Medium or Hard.

While the solutions for these problems are available directly from the site, they are directly to the point and can be a bit technical. I'd like to use these types of posts
to explain the thought process to get to the solution, and how to think about and test for edge cases. I'll be using C# in dotnet to create my solution.
Download [Visual Studio](https://visualstudio.microsoft.com/vs/community/) for free to create your own.

### The Problem

```
Given a string s, find the length of the longest substring without repeating characters.
```

The link to the problem can be found [here](https://leetcode.com/problems/longest-substring-without-repeating-characters/).

Luckily, the problem is pretty straight forward on this one and not a lot of explaination needs to go into it.
Simply put, we want to find a string within our input string that has the most unique characters. It could be the whole string itself even, who knows!

Lets look at some test cases to see some examples.

### The Test Cases

I am a huge believer in automated testing. Unit testing, integration testing, end to end testing, they are all needed to make sure you have confidence in
the quality of your code. Your product is only as good as your tests. That said, of course we're going to unit test our solution before submission!

Since this problem is pretty straight forward, I didn't need any auxilary code to help facilitate testing. That kind of stinks, because I like doing it. It's fun!

There are two test cases that stick out in my mind immediately. First, an empty string. This would and should return the value 0, because there is no substring at all.
Next, is when every character in the string is unique so the output is just the length of the string itself.

<script src="https://gist.github.com/jbasinger/ddd08a4c0f3b550e5e199326e51ca4fd.js?file=tests1.cs"></script>

Another that jumps out after thinking of all the characters being unique is, what if they are all the same character. What if there is only one character total?

<script src="https://gist.github.com/jbasinger/ddd08a4c0f3b550e5e199326e51ca4fd.js?file=tests2.cs"></script>

The last three significant tests I can think of are, what if the longest string is in the beginning of the string, the end of the string or smack dab in the middle?

<script src="https://gist.github.com/jbasinger/ddd08a4c0f3b550e5e199326e51ca4fd.js?file=tests3.cs"></script>

The most frustrating part of making these tests were trying to come up with strings that actually fit the test case I was trying to find. I kept accidentally making them
shorter or longer than they had to be and felt like I spent more time debugging the actual tests than the solution itself! But we got through it and thought of quite a 
few edge cases along the way.

### The Solution

This problem is about searching though a string for substrings. Generally in these kinds of scenarios we're going to loop inside a loop. My thought process here
is to loop through each character of the string and inside that loop, begin an inner loop that starts at the next character in the string. We'll store any character
we've seen along the way in a `Dictionary<char,bool>` and if we come across that character again, we know we finished this particular substring.

If the length of the substring we just found was the longest so far, we'll update our max length found so far, and continue to the next character in the string.

We take a couple shortcuts in the beginning of the code to cover our edge cases of string lengths 0 and 1. Here is my solution function.

<script src="https://gist.github.com/jbasinger/ddd08a4c0f3b550e5e199326e51ca4fd.js?file=solution.cs"></script>

### Conclusion

As per usual, there are many ways to solve problems like this. I, personally, try to take understandable and readable approaches. The reason being is that I generally work
with other developers. The smaller and more understandable the pieces of the puzzle are for any given problem, the easier it is to put the pieces together and fix any pieces
along the way.

You can find all my LeetCode submissions at [GitHub](https://github.com/jbasinger/LeetCode). I hope this was helpful and look forward to more problem solutions in the future.