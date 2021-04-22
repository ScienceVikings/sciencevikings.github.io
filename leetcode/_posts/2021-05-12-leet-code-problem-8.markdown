---
layout: post
title:  "LeetCode Problem 8 - String to Integer"
date:   2021-05-12 00:00:00
categories: leetcode
author: Justin
image: 
  path: /assets/img/leetcode/00008_String_to_Integer/header.png
---

## LeetCode Problem 8 - String to Integer

In this post we'll be talking about solving the 8th [LeetCode](https://leetcode.com/problems/string-to-integer-atoi/) problem. You can find my code for all my LeetCode submissions at [GitHub](https://github.com/jbasinger/LeetCode).

[LeetCode](https://leetcode.com/) is a site that provides programming problems for practice. A lot of developers use it to hone their skills or to practice for upcoming interviews.
The questions available are used by large tech companies as interview questions, so it's a good place to start and the difficulty of the questions being Easy, Medium or Hard.

While the solutions for these problems are available directly from the site, they are directly to the point and can be a bit technical. I'd like to use these types of posts
to explain the thought process to get to the solution, and how to think about and test for edge cases. I'll be using C# in dotnet to create my solution.
Download [Visual Studio](https://visualstudio.microsoft.com/vs/community/) for free to create your own.

### The Problem

Implement the myAtoi(string s) function, which converts a string to a 32-bit signed integer (similar to C/C++'s atoi function).

The algorithm for myAtoi(string s) is as follows

1. Read in and ignore any leading whitespace.
1. Check if the next character (if not already at the end of the string) is '-' or '+'. 
  * Read this character in if it is either. 
  * This determines if the final result is negative or positive respectively. 
  * Assume the result is positive if neither is present.
1. Read in next the characters until the next non-digit charcter or the end of the input is reached. The rest of the string is ignored.
1. Convert these digits into an integer (i.e. "123" -> 123, "0032" -> 32). 
  * If no digits were read, then the integer is 0. Change the sign as necessary (from step 2).
1. If the integer is out of the 32-bit signed integer range [-2^31, 23^1 - 1], then clamp the integer so that it remains in the range. 
  * Specifically, integers less than -2^31 should be clamped to -2^31, and integers greater than 2^31 - 1 should be clamped to 2^31 - 1.
1. Return the integer as the final result.

Note

1. Only the space character ' ' is considered a whitespace character.
1. Do not ignore any characters other than the leading whitespace or the rest of the string after the digits.

The link to the problem can be found [here](https://leetcode.com/problems/string-to-integer-atoi/).

Phew, that is a lot of requirements for a seemingly simple function! The important, yet easy to forget bits are dealing with whitespace, checking the sign of the string and dealing with integer bounds.
Lets take these requirments piece by piece and come up with some test cases.

### The Test Cases

I am a huge believer in automated testing. Unit testing, integration testing, end to end testing, they are all needed to make sure you have confidence in
the quality of your code. Your product is only as good as your tests. That said, of course we're going to unit test our solution before submission!

Looking at the first requirement, clearly we need a test case with a bunch of whitespace.

As for the 2nd one, we can test something like "42","+42" and "-42" to make sure we can handle the sign correctly.

The 3rd and 4th requirements let us know what to do in the case we hit a non-numeric character, in which case we stop and return the number we have thus far. If there are none, then return 0.
This gives us cases like, "+42sdionf", "-123abc", "abc123def", etc.

For the final requirement, we can just put in really big digits to make sure our return values are clamped within the integer bounds.

Last, but not least, there is __the__ test case. What do we do when the string is empty? Return 0 of course! Lets not forget to test for that as well.

Here are the cases I landed on:

```csharp
private Solution _sut = new Solution();
        
[Test]
public void ShouldConvertString()
{
    _sut.MyAtoi("42").ShouldBe(42);
    _sut.MyAtoi("12345").ShouldBe(12345);
}

[Test]
public void ShouldConvertNegativeNumbers()
{
    _sut.MyAtoi("-42").ShouldBe(-42);
    _sut.MyAtoi("-12345").ShouldBe(-12345);
}

[Test]
public void ShouldConvertPositiveNumbers()
{
    _sut.MyAtoi("+42").ShouldBe(42);
}

[Test]
public void ShouldIgnoreLeadingWhitespace()
{
    _sut.MyAtoi("              +42").ShouldBe(42);
    _sut.MyAtoi("              -42").ShouldBe(-42);
    _sut.MyAtoi("               42").ShouldBe(42);
    _sut.MyAtoi("              +42              ").ShouldBe(42);
    _sut.MyAtoi("              -42              ").ShouldBe(-42);
    _sut.MyAtoi("               42              ").ShouldBe(42);
}

[Test]
public void ShouldClampOutside32Bit()
{
    _sut.MyAtoi("9999999999").ShouldBe(int.MaxValue);
    _sut.MyAtoi("-9999999999").ShouldBe(int.MinValue);
}

[Test]
public void ShouldStopOnNonDigitCharacters()
{
    _sut.MyAtoi("42abcr123").ShouldBe(42);
    _sut.MyAtoi("-42abcr123").ShouldBe(-42);
    _sut.MyAtoi("+sdfsdf42abcr123").ShouldBe(0);
    _sut.MyAtoi("-sdfsdf42abcr123").ShouldBe(0);
}

[Test]
public void ShouldReturn0OnGibberish()
{
    _sut.MyAtoi("aiuwfbe").ShouldBe(0);
    _sut.MyAtoi("+aiuwfbe").ShouldBe(0);
    _sut.MyAtoi("-aiuwfbe").ShouldBe(0);
    
}

[Test]
public void ShouldHandleEmptyString()
{
    _sut.MyAtoi("").ShouldBe(0);
}
```

### The Solution

Here is my solution to the problem at hand:

```csharp
public class Solution
{
    public int MyAtoi(string s)
    {
        s = s.Trim();
        
        if (s.Length == 0)
            return 0;
        
        var mult = s[0] == '-' ? -1 : 1;

        try
        {
            checked
            {
                if (s[0] == '-' || s[0] == '+')
                    s = s.Remove(0,1);
        
                var num = 0;
        
                foreach (int i in s)
                {
                    if (i < 48 || i > 57)
                    {
                        return num * mult;
                    }

                    num *= 10;
                    num += i - 48;
                }

                return num * mult;
            }
        }
        catch (OverflowException)
        {
            return mult > 0 ? int.MaxValue : int.MinValue;
        }
        
    }
}
```

I start things off by trimming the whitespace from the string. Probably a bit slower than just looping and ignoring whitespace, but I like clean data.
Next, I check for the length 0 edge case and return 0 if that is true. As you can see, the trimming of the string deals with only whitespace inputs here as well, a case I didn't check for above.

After that edge case is checked, we figure out if our value needs to be positive or negative, and save that for later. We need it in it's own variable for a couple reasons. One, we need to know if our
final value is positive or negative, and also it helps us know that if a value is out of bounds for an integer, if the overflow was too high or too low.

Now, there is a try/catch and a `checked` block. Here is the actual [documentation](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/checked) on the keyword itself, 
but the TL;DR of it is that it'll throw an `OverflowException` if an integer goes out of bounds inside it's block or parens. We're kind of cheesing things here with that keyword, but if things
overflow, we catch it. If the value was negative, we return the lower bound, but if it was positive, we return the upper bound.

Since we know our sign, we can pull that character out of the string and begin looping through the characters that are left. This is probably slower than it needs to be, but if someone else were to come in
and read this code, it's very clear as to what is going on and easy to follow.

While we loop, we check to see if the character we're on is a number between 48 and 57. Those are the integer values of the number characters on the [ASCII table](http://www.asciitable.com/). If it's not in
that range, then it's not an actual number and we're done, we can return what we found times our multiplier of course.

If the character we're on is an actual number, we take our current number and multiply it by ten to make room in the 1's place for our new number. Then we subtract 48 from the character value of that number to
get the actual integer digit, and add it on.

Once we finish going through our characters, we return our new number times our multiplier to make it positive or negative and we're done!

### Conclusion

There are a lot of requirements to a function like this, and it's been recreated probably a million times by now. I think it's a decent interview question to make sure people know how strings, characters and integers
work in general. There are plenty of weird test cases you can throw at it with some fun edge cases as well.

You can find all my LeetCode submissions at [GitHub](https://github.com/jbasinger/LeetCode). I hope this was helpful and look forward to more problem solutions in the future.