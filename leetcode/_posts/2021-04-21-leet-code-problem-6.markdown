---
layout: post
title:  "LeetCode Problem 6 - ZigZag Conversion"
date:   2021-04-21 00:00:00
categories: leetcode
author: Justin
image: 
  path: /assets/img/leetcode/00006_ZigZag_Conversion/header.png
---

## LeetCode Problem 6 - ZigZag Conversion

In this post we'll be talking about solving the 6th [LeetCode](https://leetcode.com/problems/zigzag-conversion/) problem. You can find my code for all my LeetCode submissions at [GitHub](https://github.com/jbasinger/LeetCode).

[LeetCode](https://leetcode.com/) is a site that provides programming problems for practice. A lot of developers use it to hone their skills or to practice for upcoming interviews.
The questions available are used by large tech companies as interview questions, so it's a good place to start and the difficulty of the questions being Easy, Medium or Hard.

While the solutions for these problems are available directly from the site, they are directly to the point and can be a bit technical. I'd like to use these types of posts
to explain the thought process to get to the solution, and how to think about and test for edge cases. I'll be using C# in dotnet to create my solution.
Download [Visual Studio](https://visualstudio.microsoft.com/vs/community/) for free to create your own.

### The Problem

```
The string "PAYPALISHIRING" is written in a zigzag pattern on a given number of rows like this:
P   A   H   N
A P L S I I G
Y   I   R

And then read line by line: "PAHNAPLSIIGYIR"

Write the code that will take a string and make this conversion given a number of rows:

string convert(string s, int numRows);
```

The link to the problem can be found [here](https://leetcode.com/problems/zigzag-conversion/).

This problem is an interesting twist on working with strings, arrays, etc. Clearly, it is a problem from a PayPal interview. As you can see, the string makes a sawtooth pattern
with it's amplitude given by the number of rows given for the conversion. The example given with 3 rows looks like this:

```
Input: s = "PAYPALISHIRING", numRows = 3
Output: "PAHNAPLSIIGYIR"
```

So the output would be each row, excluding spaces, concatenated together.
Lets look at a couple more examples from the problem to get a better view of whats going on here.

```
Input: s = "PAYPALISHIRING", numRows = 4
Output: "PINALSIGYAHRPI"
Explanation:
P     I    N
A   L S  I G
Y A   H R
P     I
```

### The Test Cases

I am a huge believer in automated testing. Unit testing, integration testing, end to end testing, they are all needed to make sure you have confidence in
the quality of your code. Your product is only as good as your tests. That said, of course we're going to unit test our solution before submission!

The first case that stick out in my mind is if there is only 1 row. That'll just return the string itself. But, if we think about it a little bit, there is another case
that will return the same input string. That case is if the number of rows is greather than or equal to the length of the string. If that is the case, we'll get this example.

```
Input: s = "THISSTRING", numRows=10
Output: "THISSTRING"
Explanation:
T
H
I
S
S
T
R
I
N
G
```

Another one that can be a little off-putting, but managable is if there are two rows.

```
Input: s = "PAYPALISHIRING", numRows = 2
Output: "PYAIHRNAPLSIIG"
Explanation:
PYAIHRN
APLSIIG
```

This doesn't give the same effect of a zigzag that the other higher number of rows do, but it's definitely a case we're going to have to check.

Also, don't forget the cases of an empty string either! Here are the test cases I made for this problem.

```csharp
private const string paypal = "PAYPALISHIRING";
private Solution _sut = new Solution();

[Test]
public void ShouldConvertNegativeRows()
{
    _sut.Convert(paypal, -1).ShouldBe(paypal);
}

[Test]
public void ShouldConvert0Rows()
{
    _sut.Convert(paypal, 0).ShouldBe(paypal);
}

[Test]
public void ShouldConvert1Row()
{
    _sut.Convert(paypal, 1).ShouldBe(paypal);
}

[Test]
public void ShouldConvert2Rows()
{
    _sut.Convert(paypal, 2).ShouldBe("PYAIHRNAPLSIIG");
}

[Test]
public void ShouldConvert3Rows()
{
    _sut.Convert(paypal, 3).ShouldBe("PAHNAPLSIIGYIR");
}

[Test]
public void ShouldConvert4Rows()
{
    _sut.Convert(paypal, 4).ShouldBe("PINALSIGYAHRPI");
}

[Test]
public void ShouldConvertLengthRows()
{
    _sut.Convert(paypal, paypal.Length).ShouldBe(paypal);
}

[Test]
public void ShouldConvertLengthPlusNRows()
{
    _sut.Convert(paypal, paypal.Length + 2).ShouldBe(paypal);
}

[Test]
public void ShouldConvertLengthMinus1Rows()
{
    _sut.Convert(paypal, paypal.Length -1).ShouldBe("PAYPALISHIRIGN");
}
```

### The Solution

Solving this problem was pretty fun. I picture the placement of the letter in the string as bouncing. First it drops straight down, then it bounces back up at an angle, then falls down again.
My solution to this problem follows the same kind of pattern. Here is the code:

```csharp
public string Convert(string s, int numRows)
{

    if (numRows <= 1 || numRows >= s.Length)
    {
        return s;
    }

    var goingDown = true;
    var bounceIndex = 0;
    var rowStrings = new StringBuilder[numRows];

    for (var i = 0; i < numRows; i++)
    {
        rowStrings[i] = new StringBuilder();
    }
    
    foreach (var ch in s)
    {

        if (bounceIndex == 0)
        {
            goingDown = true;
        }
    
        rowStrings[bounceIndex].Append(ch);
        if (goingDown)
        {
            if (bounceIndex == numRows-1)
            {
                goingDown = false;
                bounceIndex--;
            }
            else
            {
                bounceIndex++;
            }
        }
        else
        {
            
            bounceIndex--;
            if (bounceIndex == 0)
            {
                goingDown = true;
            }
        }
    }

    var finalOutput = new StringBuilder();
    foreach (var sb in rowStrings)
    {
        finalOutput.Append(sb);
    }

    return finalOutput.ToString();

}
```

First we catch our weird edge cases, rows of length 0,1 and greater than or equal to the string's length. Next, I create a variable that tells us if our _bounce_ is traveling up
or down and a `bounceIndex` to keep track of which row we're on.

Then, to create the rows themselves, I make an array of `StringBuilder` objects, one for each row we need. Once that is done, I loop through each character in the string.

From here, we just _bounce_ from top to bottom until we run out of letters, adding a character to the `StringBuilder` to each row along the way. As you can see, the first check, if
we're at row index 0, we want to start heading down. We add our character to the string builder and go into another series of checks.

If we're heading down, but our `bounceIndex` is about to hit the bottom most row, we want to head back up and decrease the `bounceIndex`, but if we're not there yet we increase it.

If we're heading up, we just decrease the `bounceIndex` and set going down back to `true` once we hit 0 again.

Finally, once we've run out of letters to place, we append them all together in order and return the final output.

### Conclusion

I like this problem a lot as an interview question because it makes you think about strings, arrays and their bounds. There isn't really an "ah-ha! gotcha!" component to it, it just
takes a little bit of thinking to realize what is actually going on and how to solve the problem. There are good edge cases to test for as well! I hope you found this helpful

You can find all my LeetCode submissions at [GitHub](https://github.com/jbasinger/LeetCode). I hope this was helpful and look forward to more problem solutions in the future.