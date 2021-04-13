---
layout: post
title:  "LeetCode Problem 4 - Median of Two Sorted Arrays"
date:   2021-03-17 00:00:00
categories: leetcode
author: Justin
image: 
  path: /assets/img/leetcode/00004_Median_Of_Two_Sorted_Arrays/header.png
---

## LeetCode Problem 4 - Median of Two Sorted Arrays

In this post we'll be talking about solving [LeetCode](https://leetcode.com/problems/median-of-two-sorted-arrays/) problem number 4. You can find my code for all my LeetCode submissions at [GitHub](https://github.com/jbasinger/LeetCode).

[LeetCode](https://leetcode.com/) is a site that provides programming problems for practice. A lot of developers use it to hone their skills or to practice for upcoming interviews.
The questions available are used by large tech companies as interview questions, so it's a good place to start and the difficulty of the questions being Easy, Medium or Hard.

While the solutions for these problems are available directly from the site, they are directly to the point and can be a bit technical. I'd like to use these types of posts
to explain the thought process to get to the solution, and how to think about and test for edge cases. I'll be using C# in dotnet to create my solution.
Download [Visual Studio](https://visualstudio.microsoft.com/vs/community/) for free to create your own.

### The Problem

```
Given two sorted arrays nums1 and nums2 of size m and n respectively, 
return the median of the two sorted arrays.
```

The link to the problem can be found [here](https://leetcode.com/problems/median-of-two-sorted-arrays/).

In case you forget the difference between __mean__, __median__ and __mode__ like I do, lets do a quick refresher of what they actually are.

Lets say you have a list of data, `[1,1,2,3,4,5,6]`.

The __mean__ of that list, is the average. You add up all the numbers and divide by the length. `(1+1+2+3+4+5+6)/7 = 3.14`.

The __mode__ of any list is the value that shows up most frequently. In our list, it's the number `1`.

The __median__ of a list is the value that lands right in the middle. For this particular list, it is the number `3`.

I chose the list above because it would provide easy examples. The median gets a little more hairy in the case of this problem if there is an even number of items in the list.

In that case, we would that the average of the two middle elements of the array. For example, if our list was `[1,1,1,2,3,4,4,4]`, our __median__ would be `(2+3)/2 = 2.5`.

Now that we understand what a median is, lets figure out some edge cases around this problem.

### The Test Cases

I am a huge believer in automated testing. Unit testing, integration testing, end to end testing, they are all needed to make sure you have confidence in
the quality of your code. Your product is only as good as your tests. That said, of course we're going to unit test our solution before submission!

To fascilitate testing, I wrote a function that will find the median of a list of numbers for us.

```csharp
public static double MedianOfArray(int[] nums)
{
    if (nums.Length == 0)
        return 0;

    if (nums.Length == 1)
        return nums[0];

    if (nums.Length % 2 == 0)
    {
        return ((double) (nums[nums.Length / 2] + nums[(nums.Length / 2) - 1])) / 2;
    }

    return nums[nums.Length/2];
}
```

Now, in the unit tests we can pass it the merged list and check our solution against that making it easier to test everything.

Just looking at the examples given by the problem, we can see a few edge cases.

![Examples](../images/leetcode-4/examples.png)

What if one of the arrays is empty? Then we only need the median of the non-empty array.
We need to make sure we can test a single empty array, and also the case if both arrays are empty, in which case I make my code just return 0.

For other ideas of test cases, lets thing about how things can line up with medians of two arrays. 
Going further, I'll refer to the first array as array A and the second as array B.

Because there are two arrays, the tests tend to come to my mind in pairs. For example, lets say that all the values in A are smaller than all the values in B.
When we think about it that way, the opposite case almost immediately comes to mind. Also, __don't__ __forget__ the cases of the arrays being __even__ in length, so that
you need to average the two median numbers as well.

I'll keep the opposite test cases at a minimum for the sake of breavity. Please enjoy my crude ASCII art comment examples as well!

```csharp
/*
 * A [--|--]
 * B            [--|--]
 */
[Test]
public void AllOfAIsLessThanB()
{
    var nums1 = new int[]{1,2,3,4};
    var nums2 = new int[]{10,11,12,13,14};
    var appended = new int[] {1, 2, 3, 4, 10, 11, 12, 13, 14};
    var val = MedianOfTwoSortedArrays_Problem.MedianOfArray(appended);
    _sut.FindMedianSortedArrays(nums1, nums2).ShouldBe(val);
}
```

Now lets setup a test case when both A and B are different, but their medians happen to be the same.

```csharp
/*
 * A   [--|--]
 * B [----|---]
 */
[Test]
public void AandBMediansAreEqual()
{
    var nums1 = new int[]{1,1,2,3,4};
    var nums2 = new int[]{0,1,2,3,4};
    var appended = new int[] {0, 1, 1, 1, 2, 2, 3, 3, 4, 4};
    var val = MedianOfTwoSortedArrays_Problem.MedianOfArray(appended);
    _sut.FindMedianSortedArrays(nums1, nums2).ShouldBe(val);
}
```

We can also think about what would happen if A had a subset of B, but the median of A was less than B.

```csharp
/*
 * A [--|---]
 * B  [---|--]
 */
[Test]
public void AisInBbutLessThanBMedian()
{
    var nums1 = new int[]{-1,0,1,2,3,4};
    var nums2 = new int[]{0,1,2,3,4};
    var appended = new int[] {-1,0,0,1,1,2,2,3,3,4,4};
    var val = MedianOfTwoSortedArrays_Problem.MedianOfArray(appended);
    _sut.FindMedianSortedArrays(nums1, nums2).ShouldBe(val);
}
```

Another case I thought of was what if they are, basically, completely mixed in with one another and alternate. For example A is all even numbers and B is all odd.

```csharp
[Test]
public void AllMixedIn()
{
    var nums1 = new int[] {0, 2, 4, 6, 8};
    var nums2 = new int[] {1, 3, 5, 7, 9};
    var appended = new int[] {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
    var val = MedianOfTwoSortedArrays_Problem.MedianOfArray(appended);
    _sut.FindMedianSortedArrays(nums1, nums2).ShouldBe(val);

    nums1 = new int[] {2, 4, 6, 8};
    nums2 = new int[] {1, 3, 5, 7};
    appended = new int[] {1, 2, 3, 4, 5, 6, 7, 8};
    val = MedianOfTwoSortedArrays_Problem.MedianOfArray(appended);
    _sut.FindMedianSortedArrays(nums1, nums2).ShouldBe(val);
}
```

And finally, a couple weird ones I thought were neat. One where the entirety of A lands somewhere in B and the other where A is all the same number, and B carries on a bit.

```csharp
[Test]
public void WeirdOnesIThoughtWereNeat()
{
    var nums1 = new int[]{1,1,1,100,100,100};
    var nums2 = new int[]{50,50,50};
    var appended = new int[] {1,1,1,50,50,50,100,100,100};
    var val = MedianOfTwoSortedArrays_Problem.MedianOfArray(appended);
    _sut.FindMedianSortedArrays(nums1, nums2).ShouldBe(val);

    nums1 = new int[] {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
    nums2 = new int[] {1, 2, 3, 4, 5};
    appended = new int[] {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 4, 5};
    val = MedianOfTwoSortedArrays_Problem.MedianOfArray(appended);
    _sut.FindMedianSortedArrays(nums1, nums2).ShouldBe(val);

}
```

Some of these cases are a bit redundant, but I like knowing that my code will cover things the way I think about them and I'm willing to sacrifice a little bit of test
efficiency for that piece of mind.

### The Solution

This is considered a Hard level problem on LeetCode, and that is because the expectation is to come up with a solution using a binary search. The hint at that is near the
bottom of the problem page that says, "The overall run time complexity should be `O(log(m+n))`". Any time you're looking for a logarithmic time complexity, you're using some kind
of binary tree structure or searching algorithm.

For this, I solved the naive solution. I banged my head against the wall for far too long trying to sort out the logarithmic approach and came to an interesting justification for myself
to stop and leave the easy solution where it was. 

It's simply more realistic. 

If you're working with group of other developers, you're all touching the same code. Writing code that will never be touched again is simply never going to happen. If you're going out
of your way to pre-maturely optimize a more simple solution then you're making that code harder to read, harder to understand and harder to maintain.

Now, this probably just sounds like an excuse to say I wasn't smart enough to figure it out and I'll definitely admit that I am not. Perhaps I'll come back to it some day and understand it
but, my justification of why the naive approach is better definitely holds water.

All that said and put aside, the _naive_ approach still feels pretty clever. Consider this, when finding the median of a sorted array, we only need to look in the first half-ish of the array itself.
If the length of the array is `N`, worst case scenario we only care about values at indicies `<= N/2+1`. That is to say, if we have 10 elements in the array, we only care about elements 1 through 6.

So with that, and the fact that we know both of our input arrays are sorted for us, we've already solved half our problems. We simply need to make a new array that is half the length of the arrays combined,
`+1` if the length is even, and fill it with the lowest values of the two arrays. Our median will be the last element of that array! Or, average of the last two if the sum of the lengths was even.

What I did was create that array and then stored two indicies, one for the current index of A and another for B both starting at 0 called Ai and Bi respectively. If the value of Ai was less than
Bi, then we added that number to the new array and incremented Ai and visa versa if the value at Bi was the smaller number.

Here is the final function with all the checks for empty arrays and what not.

```csharp
public double FindMedianSortedArrays(int[] nums1, int[] nums2)
{

    if (nums1.Length == 0 && nums2.Length == 0)
        return 0;

    if (nums1.Length == 0)
        return MedianOfArray(nums2);

    if (nums2.Length == 0)
        return MedianOfArray(nums1);

    var totalLength = nums1.Length + nums2.Length;
    var arrLength = totalLength / 2+1;

    var buf = new int[arrLength];
    var Ai = 0;
    var Bi = 0;
    for (int i = 0; i < arrLength; i++)
    {
        if (Ai == nums1.Length)
        {
            buf[i] = nums2[Bi++];
            continue;
        }

        if (Bi == nums2.Length)
        {
            buf[i] = nums1[Ai++];
            continue;
        }


        if (nums1[Ai] < nums2[Bi])
            buf[i] = nums1[Ai++];
        else
            buf[i] = nums2[Bi++];

    }

    if (totalLength % 2 == 0)
    {
        return (buf[arrLength - 1] + buf[arrLength - 2]) / 2d;
    }
    return buf[arrLength - 1];

}
```

The time complexity of this solution is `O(N)` and I know what you're thinking, "but you cut the total length in half!" and I certainly did. Remember, that N times a constant in time complexity, is still 
just N. So, `O(N/2)` still turns out to be `O(N)`. This is unintuitive, to say the least, and maybe I can shed some light on it. Time complexity factors in the worst case, lets say that A was much, much longer
than B. We would spend most of our time iterating through A to find our median where with a logarithmic approach we would be cutting the amount of elements left in half at every step.

### Conclusion

Being confronted with a problem like this at a job interview would be enough to make anyone sweat. The solution for this problem on the LeetCode site for the logarithmic approach looks like
you need a PhD in mathematics to even crack the surface. While I banged my head on it for far too long and recontemplated my entire career as a developer, it still was nice to get a simple
approach to work in the end. If you have a simple way to explain the binary search solution to me, please feel free to contact me and tell me "the trick".

You can find all my LeetCode submissions at [GitHub](https://github.com/jbasinger/LeetCode). I hope this was helpful and look forward to more problem solutions in the future.