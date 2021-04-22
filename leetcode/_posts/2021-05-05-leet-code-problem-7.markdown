---
layout: post
title:  "LeetCode Problem 7 - Reverse Integer"
date:   2021-05-05 00:00:00
categories: leetcode
author: Justin
image: 
  path: /assets/img/leetcode/00007_Reverse_Integer/header.png
---

## LeetCode Problem 7 - Reverse Integer

In this post we'll be talking about solving the 7th [LeetCode](https://leetcode.com/problems/reverse-integer/) problem. You can find my code for all my LeetCode submissions at [GitHub](https://github.com/jbasinger/LeetCode).

[LeetCode](https://leetcode.com/) is a site that provides programming problems for practice. A lot of developers use it to hone their skills or to practice for upcoming interviews.
The questions available are used by large tech companies as interview questions, so it's a good place to start and the difficulty of the questions being Easy, Medium or Hard.

While the solutions for these problems are available directly from the site, they are directly to the point and can be a bit technical. I'd like to use these types of posts
to explain the thought process to get to the solution, and how to think about and test for edge cases. I'll be using C# in dotnet to create my solution.
Download [Visual Studio](https://visualstudio.microsoft.com/vs/community/) for free to create your own.

### The Problem

```
Given a signed 32-bit integer x, return x with its digits reversed. 
If reversing x causes the value to go outside the signed 32-bit integer range [-2^31, 2^31 - 1], then return 0.
```

Basically, take an integer, reverse it and return it back. If it's negative, keep it negative. If it's out of the 32-bit signed range, return 0.

This problem seems pretty straight forward to me, until keeping it in the 32-bit range part came along. I had forgotten about it in my first submission of the solution, so it failed.

I'll share how I sort of cheesed it with a special C# keyword in the solution section. But first, lets check out the tests.

### The Test Cases

I am a huge believer in automated testing. Unit testing, integration testing, end to end testing, they are all needed to make sure you have confidence in
the quality of your code. Your product is only as good as your tests. That said, of course we're going to unit test our solution before submission!

There aren't too many test cases for a problem like this. It's kind of either works, or doesn't. It is either in bounds, or it isn't.
We need to check for things like, trailing zeros, zero itself, numbers in and out of bounds and negatives. Here are the cases I came up with:

```csharp
private Solution _sut = new();
        
[Test]
public void ShouldReverseNumbers()
{
    _sut.Reverse(123).ShouldBe(321);
    _sut.Reverse(12345).ShouldBe(54321);
}

[Test]
public void ShouldReverseNegativeNumbers()
{
    _sut.Reverse(-123).ShouldBe(-321);
}

[Test]
public void ShouldReturnZeroOnZero()
{
    _sut.Reverse(0).ShouldBe(0);
}

[Test]
public void ShouldCountZeroAsZero()
{
    _sut.Reverse(10001).ShouldBe(10001);
    _sut.Reverse(120).ShouldBe(21);
    _sut.Reverse(1200).ShouldBe(21);
    _sut.Reverse(12000).ShouldBe(21);
    _sut.Reverse(1201).ShouldBe(1021);
}

[Test]
public void ShouldOnlyCount32BitNumbers()
{
    _sut.Reverse(1534236469).ShouldBe(0);
    _sut.Reverse(-1534236469).ShouldBe(0);
}
```

A few of the tests cover the same kind of case. It's a bit inefficient, but then again, test cases are there to boost your confidence in your code. If a test case
is technically inefficient, but it helps you feel like your code is working properly, leave it.

### The Solution

Let me just start off with a drawing of my thought process here, then feel free to laugh at my ASCII art.

```
 123
   V
   3

  12
   V
 3<2

   1
   V
32<1

321 //Hooray!
```

The idea is to pull of the 1's place of the original, put it in the 1's place of our new number, but first shifting the number we have over a 10's spot to make room.
Sound confusing? Good because it is. Let me show you my code solution, then explain it further:

```csharp
public int Reverse(int x)
{

    if (x == 0 || x > Int32.MaxValue || x < Int32.MinValue)
        return 0;
    
    try
    {
        var mult = x < 0 ? -1 : 1;
        var rev = 0;
    
        if (x < 0)
            x *= -1;
    
        while (x != 0)
        {
            rev = checked((rev * 10) + (x % 10)); //write about the overflow bit
            x /= 10;
        }

        return rev * mult;
    }
    catch (OverflowException)
    {
        return 0;
    }
    
}
```

First we're checking a couple of our edge cases. If we're 0, too big or too small, return 0.

Next, you see a try/catch for an overflow exception. I'll talk about this and the `checked` keyword more once I get through the heart of what is going on.

Then, we check to see if the number is negative. If it is, we'll want our output to also be negative. Other than that, we don't really care so we can set the input value to be positive as well.

After that, you see a while loop. This is us checking to see if our original number is zero or not. While it is _not_ zero we'll take our current reversed number, `rev` and multiply it by 10.
That will move shift the number over and make room for our new one in the 1's place. Then, we get the 1's place of the input number by taking the `mod 10` of it which gives us the remainder of a division operation.

Once that is complete, we divide our original number by 10 and since this is integer math, the fractional part is just truncated for us. We keep looping until our original number is zero and then return our
reversed number, times our multiplier.

Lets loop back to the try/catch and `checked` keyword. This is our cheese for the out of bounds integers. Here is the actual [documentation](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/checked) on
the keyword itself, but the TL;DR of it is that it'll throw an `OverflowException` if an integer goes out of bounds inside it's block or parens. So, with that we can check if anything goes out of bounds and then just
return 0 if it does, so that requirement is met.

### Conclusion

While this problem was rated easy, I'd say it isn't exactly a stroll through the park considering the bounds checking requirement. None the less, it was a fun problem to figure out and solve.
I hope you learned something new with this problem. I know I certainly did with the `checked` keyword in .net. There is also an `unchecked` version which can be used to ignore overflow checking as well!

You can find all my LeetCode submissions at [GitHub](https://github.com/jbasinger/LeetCode). I hope this was helpful and look forward to more problem solutions in the future.