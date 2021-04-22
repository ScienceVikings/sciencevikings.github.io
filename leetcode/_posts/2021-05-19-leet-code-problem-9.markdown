---
layout: post
title:  "LeetCode Problem 9 - Palindrome Number"
date:   2021-05-19 00:00:00
categories: leetcode
author: Justin
image: 
  path: /assets/img/leetcode/00009_Palindrome_Number/header.png
---

## LeetCode Problem 9 - Palindrome Number

In this post we'll be talking about solving the 9th [LeetCode](https://leetcode.com/problems/palindrome-number/) problem. You can find my code for all my LeetCode submissions at [GitHub](https://github.com/jbasinger/LeetCode).

[LeetCode](https://leetcode.com/) is a site that provides programming problems for practice. A lot of developers use it to hone their skills or to practice for upcoming interviews.
The questions available are used by large tech companies as interview questions, so it's a good place to start and the difficulty of the questions being Easy, Medium or Hard.

While the solutions for these problems are available directly from the site, they are directly to the point and can be a bit technical. I'd like to use these types of posts
to explain the thought process to get to the solution, and how to think about and test for edge cases. I'll be using C# in dotnet to create my solution.
Download [Visual Studio](https://visualstudio.microsoft.com/vs/community/) for free to create your own.

### The Problem

```
Given an integer x, return true if x is palindrome integer.
An integer is a palindrome when it reads the same backward as forward. 
For example, 121 is palindrome while 123 is not.
```

The link to the problem can be found [here](https://leetcode.com/problems/palindrome-number/).

This is a problem that is kind of a mash up between problems [5](https://leetcode.com/problems/longest-palindromic-substring/) and [7](https://leetcode.com/problems/reverse-integer/).
Not only do we need to look for palindromes, but we'll be using similiar techniques to reverse an integer to make sure it's a palindrome as well.

There are a few caveats to this problem. For example, if a number is negative it will not be a palindrome. The example given is `-121`. While as a positive integer this is a palindrome
the negative value would be `121-` which is _not_ a palindrome.

Another example is `10` or `100`. These are also not palindromes as they would read `01` and `001` respectively.

### The Test Cases

I am a huge believer in automated testing. Unit testing, integration testing, end to end testing, they are all needed to make sure you have confidence in
the quality of your code. Your product is only as good as your tests. That said, of course we're going to unit test our solution before submission!

There is one thing that sticks out immediately when looking at these requirements. Anything less than 0 is _not_ going to be a palindrome. So those cases are easy.

After that it's just checking any other case we want.

```csharp
private Solution _sut = new();

[Test]
public void ShouldHandleNegativeNumbers()
{
    _sut.IsPalindrome(-101).ShouldBeFalse();
    _sut.IsPalindrome(-10).ShouldBeFalse();
    _sut.IsPalindrome(-999).ShouldBeFalse();
    _sut.IsPalindrome(int.MinValue).ShouldBeFalse();
}

[Test]
public void ShouldHandlePositiveNumbers()
{
    _sut.IsPalindrome(101).ShouldBeTrue();
    _sut.IsPalindrome(123).ShouldBeFalse();
    
    _sut.IsPalindrome(10).ShouldBeFalse();
    
    _sut.IsPalindrome(1).ShouldBeTrue();
    _sut.IsPalindrome(123454321).ShouldBeTrue();
    _sut.IsPalindrome(1233321).ShouldBeTrue();
    _sut.IsPalindrome(123445321).ShouldBeFalse();
    
    _sut.IsPalindrome(int.MaxValue).ShouldBeFalse();
    
}
```

As you can see, the there are a few palindromes and non-palindromes in there. A test case against a single digit, and also cases to check against integer bounds.

These interview questions really want you to know how small and big these primatives can be.

Lets check out how I made these tests pass.

### The Solution

This solution almost directly steals from my solution for [problem 7]({% post_url leetcode/2021-05-05-leet-code-problem-7 %}). 
We're going to simply reverse the integer and see if it's matches.

```csharp
public class Solution
{
    public bool IsPalindrome(int x)
    {
        if (x < 0)
            return false;
        
        if (x < 10)
            return true;

        var rev = 0;
        var orig = x;
        while (x != 0)
        {
            rev = (rev * 10) + (x % 10);
            x /= 10;
        }

        return rev == orig;
    }
}
```

First, our edge cases. If we're less than 0, we can't ever be a palindrome because the reverse would end with a negative.
If our input is ever less than 10, it's going to be a single digit and therefore, always a palindrome as well so return that as true. 
This covers cases from negative infinity to 9, what about the rest?

Next, we initialize our reversed digit. Then store the original, because we're going to loop through the input until it's 0.
For each iteration, we multiply the value we have currently by 10 to make room in the 1's place for our new integer. 
Then we divide by 10 and do it again, reversing the integer one value at a time.

Once we're done reversing, we check it against the original input and return the result. If it's the same forward as it is backward, it's a palindrome.

### Conclusion

This was a pretty quick question to go through, especially having done posts about [palindromes]({% post_url leetcode/2021-03-24-leet-code-problem-5 %}) and [reversing integers]({% post_url leetcode/2021-05-05-leet-code-problem-7 %}) in the past.

I think it's an appropriate easy level interview question. It covers some basic edge cases thought processes, looping and a little bit of math. 
Just enough to make sure the person you're interviewing at least knows some basics of programming.

You can find all my LeetCode submissions at [GitHub](https://github.com/jbasinger/LeetCode). I hope this was helpful and look forward to more problem solutions in the future.