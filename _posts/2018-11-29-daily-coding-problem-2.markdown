---
layout: post
title:  "Daily Coding Problem # 2"
date:   2018-11-29 22:03:00 +7000
categories: coding problem
---

One new day and one new problem to solve:

> Given an array of integers, return a new array such that each element at index i of the new array is the product of all the numbers in the original array except the one at i.
> For example, if our input was [1, 2, 3, 4, 5], the expected output would be [120, 60, 40, 30, 24]. If our input was [3, 2, 1], the expected output would be [2, 3, 6].
>
> Follow-up: what if you can't use division?

#### Solution

{% highlight c# %}
public class ProductsOfAllButItself
{
    public static int[] Evaluate(int[] input)
    {
        //init array with ones
        int[] res = Enumerable.Repeat(1, input.Length).ToArray();
        int zeroCount = 0;
        for (int i = 0; i < input.Length; i++) {
            //handle cases with 2 zeroes which would make
            //a zero values array and we do not need to evaluate 
            //anything else
            if(input[i] == 0) {
                zeroCount++;
            }
            if (zeroCount == 2) {
                var result = new List<int>();
                for (int j = 0; j < input.Length; j++) {
                    result.Add(0);
                }
                return result.ToArray();
            }
            for (int k = 0; k < input.Length; k++) {
                if(k == i) {
                    //multiple for all but itself
                    continue;
                }
                else {
                    res[k] = res[k] * input[i];
                }
            }
        }
        return res;
    }
}
{% endhighlight %}

### Explanation
So my first idea was simple, get the overall product of the array (so we would do an O(n) pass) and then do one last pass to iterate over it again, dividing the actual value over the sum and bingo! we have an O(2N) solution

So:

totalProduct = 1 * 2 * 3 * 4 * 5 = 120

Then we divide every element to get each individual value

* Index(0) would be 120 / 1 = 120
* Index(1) would be 120 / 2 = 60
* Index(2) would be 120 / 3 = 40
* Index(3) would be 120 / 4 = 30
* Index(4) would be 120 / 5 = 24

Profit! Right?

We didn't get any guarantee over the values in the array, if the problem stated that O(N) elements were values > 1 then that would work. But if we get one single zero here.. the operation fails. That's what that little insight at the end of the problem talks about as this would be one reason we can't use division at all.

So we are now thinking on edge cases.

1 zero would be manageable. Only the position where the zero is located would be multipled by all the other values, so if instead we had 6 elements in the input array [0, 1, 2, 3, 4, 5] then the result would be [120, 0, 0, 0, 0, 0].
To come up with 120, we still need to iterate over all the elements except the current one so this still holds true.

What if we have 2 zeroes?

Then multiplication doesn't matter anymore! You just need to return an array of length input.Length filled with zeroes and you are good to go!
This is what I did with my code. I count how many times I have found zeroes, if its one it is ok, I need to iterate over all elements N anyway, but having 2, I can just disregard my current calculations and return an array of zeroes. Otherwise I go my merry way and keep multiplying all numbers, except the current iteration, and multiply each of them.

The manual run would look like this, remembering that at every iteration we don't multiply the current value by itself:

1. Initialize the result array to [1, 1, 1, 1, 1]
2. Iterating over 1 so everything stays the same, still [1, 1, 1, 1, 1]
3. Iterating over 2 so now we have [2, 1, 2, 2, 2]
4. Iteraring over 3 so it is now [6, 3, 2, 6, 6]
5. Iterating over 4 results in [24, 12, 8, 6, 24]
6. Last but not least, multiply by 5 so we end up with [120, 60, 40, 30, 24]

And we did all in one pass so it is O(N) time! (Disregarding that time we initialized our result array with 1s)

That's all for today. Remember to be on the lookout for edge cases when attempting to solve your problems as these can change the way the solution will work and ask clarifying questions all the time. If an interviewer told me I should not worry about zeroes then the first solution would have worked without problems, but thinking on special cases can lead to design changes on our algorithm.

> Na lû e-govaned 'wîn
