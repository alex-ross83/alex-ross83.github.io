---
layout: post
title:  "Daily Coding Problem # 4"
date:   2018-12-06 22:52:30 +7000
categories: coding problem
---

A new problem for today's post! We are playing with the rules here and I'm also using a different language to solve this one:

> Given an array of integers, find the first missing positive integer in linear time and constant space. In other words, find the lowest positive integer that does not exist in the array. The array can contain duplicates and negative numbers as well.
>
> For example, the input [3, 4, -1, 1] should give 2. The input [1, 2, 0] should give 3.
> You can modify the input array in-place.

#### Solution

Javascript:

{% highlight javascript %}

function FindNextPositiveMissingNumber(input){
  var next = 1;
  input.sort();
  for(var i = 0; i < input.length; i++){
    if(input[i] > 0){
      if(input[i] > next){
        break;
      } else {
        next = input[i] + 1;
      }
    }
  }
  return next;
}

{% endhighlight %}

### Explanation

The fact that they say that the array can be modified means we can do as we please with it so my solution involved:

1. Sorting the input array
2. Iterate over it and for each element compare if it is not a negative number, if it is we just discard and continue
3. If the number is greater than what we think should be the next positive integer, we know that our next positive integer is the number we were looking for.
4. Otherwise we 1-up the current number as it should be the next positive integer number.

We played with the rules a little bit here, first by using a built-in method, which is totally valid in interviews but can be clarified before using it, i.e. I hinted a candidate that was struggling with obtaining the size of an array in a C++ example to use sizeof function to calculate the number of elements in an array, as I was not expecting the candidate to write a low-level implementation of it. (By the way, sizeof(array) / sizeof(array[0]) would be the calculation to use in that case).

We explained how we got our solution and also I am recommending to ask clarifying questions. Some people like me tend to over complicate solutions but, given the amount of time that is available in a single interview session it is totally ok sometimes to ask if its possible to use a built-in method, as long as you know how it works. Besides I'm pretty sure the team you are interviewing with is not using all in-house-developed sorting operations, but hey, I could be wrong, so just ask!

> Na lû e-govaned 'wîn
