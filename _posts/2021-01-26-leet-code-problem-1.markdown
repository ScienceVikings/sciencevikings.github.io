---
layout: post
title:  "LeetCode Problem 1 - Two Sum"
date:   2021-01-26 00:00:00
categories: "leetcode testing"
author: Justin
---

## LeetCode Problem 1 - Two Sum

Today we're going to be sharpening the axe a bit and doing the first [LeetCode](https://leetcode.com/problems/two-sum/) problem. You can find my code for all my LeetCode submissions at [GitHub](https://github.com/jbasinger/LeetCode).

[LeetCode](https://leetcode.com/) is a site that provides programming problems for practice. A lot of developers use it to hone their skills or to practice for upcoming interviews.
The questions available are used by large tech companies as interview questions, so it's a good place to start and the difficulty of the questions being Easy, Medium or Hard.

While the solutions for these problems are available directly from the site, they are directly to the point and can be a bit technical. I'd like to use these types of posts
to explain the thought process to get to the solution, and how to think about and test for edge cases. I'll be using C# in dotnet to create my solution.
Download [Visual Studio](https://visualstudio.microsoft.com/vs/community/) for free to create your own.

### The Problem

```
Given an array of integers nums and an integer target, 
return indices of the two numbers such that they add up to target.

You may assume that each input would have exactly one solution, 
and you may not use the same element twice.

You can return the answer in any order.

Example 1

Input: nums = [2,7,11,15], target = 9
Output: [0,1]
Output: Because nums[0] + nums[1] == 9, we return [0, 1].

Example 2

Input: nums = [3,2,4], target = 6
Output: [1,2]

Example 3

Input: nums = [3,3], target = 6
Output: [0,1]

```

The link to the problem can be found [here](https://leetcode.com/problems/two-sum/). 

So, basically, we're given a list of numbers and another number. We need to find the two numbers in that list that adds up to the other number.
Simple, right? You may think so! There are a few different ways to attack the problem. The time complexity can get down to O(n). That's a fancy way
of saying you can answer the problem by only going through the list once. But, for simplicity's sake, we're going to use the O(n<sup>2</sup>) method.
That means, we'll be looping through the list while we're looping through the list, Pimp My Array style.

### The Solution

Here is my take on the brute force method:

<script src="https://gist.github.com/jbasinger/e67b70cb504773c5cda387e41bee3f9f.js?file=twosum.cs"></script>

As you can see, first I loop through the list of numbers passed. Then, I start a second loop on the list, but one index ahead, so we don't add a number to itself.
That would be against the rules! 

Then, we check if the numbers we are currently at add up to our target. If they do, we return the indicies of those numbers as an array.
Easy as pie! But wait, there is more.

### You're only as good as your tests

I am a huge believer in automated testing. Unit testing, integration testing, end to end testing, they are all needed to make sure you have confidence in
the quality of your code. Your product is only as good as your tests. That said, of course we're going to unit test our solution before submission!

Lets think about some edge cases.

- The numbers we need are literally at the edges of the list. The first and last items in the array add up to our target number.
- There are only two items in our list.
- The numbers are somewhere in the middle of our list. We expect this case to be the most common.

Here are my test cases:

<script src="https://gist.github.com/jbasinger/e67b70cb504773c5cda387e41bee3f9f.js?file=twosum_tests.cs"></script>

I'm using the package [Shouldly](https://www.nuget.org/packages/Shouldly/) to assert my results. The rest is just standard [xUnit](https://xunit.net/).

Here is my thought process on tackling unit testing. First, either write an interface your class is going to use. Next, write the function and make it just throw an exception for now. 
We just need the signature. Then, think of a few edge cases that stick out to you. Write some tests that check those results, compile and fail.

Now, start working on your main code. Write until tests pass. While you're writing, you'll likely come up with other test cases you haven't thought of yet.
If your tests are failing, but you think they should be passing, debug your test case and see what is up.

Having a test harness is your best friend. It will help you write code more easily, and be more confident about what you're writing. 
The best part is that you can make sure you don't break something you didn't think about by accident when you change something totally unrelated!

### Conclusion

In the end, this problem is pretty straight forward if you go through it the brute force way. There are certainly other ways of solving this problem, but I mostly
wanted to show how to setup the problem and think about unit testing to be more confident in your code. Again, you can find all my LeetCode submissions at [GitHub](https://github.com/jbasinger/LeetCode). I hope this was helpful and look forward to more problem solutions in the future.