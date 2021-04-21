---
layout: post
title:  "LeetCode Problem 5 - Longest Palindromic Substring"
date:   2021-03-24 00:00:00
categories: leetcode
author: Justin
image: 
  path: /assets/img/leetcode/00005_Longest_Palindromic_Substring/header.png
---

## LeetCode Problem 5 - Longest Palindromic Substring

In this post we'll be talking about solving the fifth [LeetCode](https://leetcode.com/problems/longest-palindromic-substring/) problem. You can find my code for all my LeetCode submissions at [GitHub](https://github.com/jbasinger/LeetCode).

[LeetCode](https://leetcode.com/) is a site that provides programming problems for practice. A lot of developers use it to hone their skills or to practice for upcoming interviews.
The questions available are used by large tech companies as interview questions, so it's a good place to start and the difficulty of the questions being Easy, Medium or Hard.

While the solutions for these problems are available directly from the site, they are directly to the point and can be a bit technical. I'd like to use these types of posts
to explain the thought process to get to the solution, and how to think about and test for edge cases. I'll be using C# in dotnet to create my solution.
Download [Visual Studio](https://visualstudio.microsoft.com/vs/community/) for free to create your own.

### The Problem

```
Given a string s, return the longest palindromic substring in s.
```

The link to the problem can be found [here](https://leetcode.com/problems/longest-palindromic-substring/).

Lets quickly go over what a __palindrome__ is. A palindrome is a word or string that is spelt the same way forward as it is backward.

A few examples are racecar, kayak, or tacocat, or _saippuakivikauppias_, which is apparently Finnish for soapstone vendor.

They are fun and useful for coding problems and showing us all how easy it is to find every off-by-one error in existance.

### The Test Cases

I am a huge believer in automated testing. Unit testing, integration testing, end to end testing, they are all needed to make sure you have confidence in
the quality of your code. Your product is only as good as your tests. That said, of course we're going to unit test our solution before submission!

Thinking about test cases around strings and finding things in them can be frustrating at times. We always have the common ones, empty or null strings, 
extra whitespace and strings fo length 1. But, for this problem we need to figure out some other edge cases.

The first few that stick out to me are the cases where the palindrome is in the beginning of the string, make up the end of the string, or are smack dab in
the middle.

```csharp
[Test]
public void PalindromeInTheBeginning()
{
    _sut.LongestPalindrome("babad").ShouldBe("bab");
}

[Test]
public void PalindromeInTheMiddle()
{
    _sut.LongestPalindrome("cbbd").ShouldBe("bb");
}

[Test]
public void PalindromeAtTheEnd()
{
    _sut.LongestPalindrome("asedad").ShouldBe("dad");
}
```

Once I started working on solving those cases, I knew there had to be a couple more weird ones. I re-read the question to make sure I didn't miss anything simple
and sure enough I did. What if the entire string is the palindrome, or there is no palindrome at all? 

```csharp
[Test]
public void PalindromeIsTheWholeString()
{
    _sut.LongestPalindrome("racecar").ShouldBe("racecar");
}

[Test]
public void NoPalindromes()
{
    _sut.LongestPalindrome("ab").ShouldBe("a");
}
```

### The Solution

Now that we have our test cases ready, lets figure this problem out. I'm sure there are super fancy `O(n)` approaches to this problem, but I decided to brute force it.

The idea is that we'll walk through the string, character by character, and then start at the end of the string on an inner loop and work our way backward looking for the
same character we're on. If we find a match, we've found a potential palindrome.

From there, we'll use those indicies to build a new string, checking to make sure it's a palindrome along the way. If our new palindrome is longer than any other we've found,
we set it as the newest and go along our merry way.

This works, and is a big brute force way to do it. I submitted the answer to LeetCode and it told me my speed was in the bottom 6% of submissions. Yikes. We can do better.

So in setting out to do less calculations, I checked the length of what the new potential palindrome could be before putting in the work of building it and it increased it to 
almost 20%!

Here is my function for finding the longest palindrome.

```csharp
public string LongestPalindrome(string s)
{
    if (s.Length == 0 || s.Length==1)
        return s;

    var longestPali = s[0].ToString();

    for (var i = 0; i < s.Length; i++)
    {
        //Walk backward until you find the same character then start looking for a palindrome
        for (var j = s.Length - 1; j >= i; j--)
        {
            if (s[i] == s[j]) //Potential Palindrome
            {

                var len = j - i+1;

                //If the length is smaller than our current one, why bother!
                if (len <= longestPali.Length)
                    continue;

                var isPalindrome = true;
                var tempPali = new char[len];

                for (int front = i, back = j, first = 0, last = len-1; front <= back; front++, back--, first++, last--)
                {
                    if (s[front] != s[back])
                    {
                        isPalindrome = false;
                        break;
                    }

                    tempPali[first] = s[front];
                    tempPali[last] = s[back];
                }

                var newPali = new string(tempPali);
                if (isPalindrome && newPali.Length > longestPali.Length)
                {
                    longestPali = newPali;
                }

            }
        }

    }

    return longestPali;
}
```

### Conclusion

This was a fun problem to solve, although I must've gotten a hundred index out of bounds errors on my tests along the way. That is exactly why I love being able to setup
test harnesses to make sure I solve the problem correctly for all cases. Fast feedback loops let you be more productive and confident in your work.

You can find all my LeetCode submissions at [GitHub](https://github.com/jbasinger/LeetCode). I hope this was helpful and look forward to more problem solutions in the future.