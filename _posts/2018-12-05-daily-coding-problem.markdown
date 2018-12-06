---
layout: post
title:  "Daily Coding Problem #3"
date:   2018-11-28 20:21:52 +7000
categories: coding problem
---

Taking a bit longer but here it is a new problem to solve!

> Given the root to a binary tree, implement serialize(root), which serializes the tree into a string, and deserialize(s), which deserializes the string back into the tree.
>
>For example, given the following Node class
>
>class Node: 
>	def init(self, val, left=None, right=None): 
>		self.val = val 
> 		self.left = left 
> 		self.right = right 
> 
> The following test should pass:
>
> node = Node(‘root’, Node(‘left’, Node(‘left.left’)), Node(‘right’)) 
> assert deserialize(serialize(node)).left.left.val == ‘left.left’

This one is written in Python as the problem is stated.

### Solution

{% highlight python %}

class Node:
	def __init__(self, val, left=None, right=None):
		self.val = val
 		self.left = left
 		self.right = right

def serialize(node):
    if(node == None):
        return "@"
    return node.val + ',' + serialize(node.left) + ',' + serialize(node.right)

def deserialize(strNode):
    strList = iter(strNode.split(','));
    def deserializeIn():
        curVal = next(strList)
        if(curVal == "@"):
            return None
        n = Node(curVal, deserializeIn(), deserializeIn());
        return n;
    return deserializeIn()

{% endhighlight %}


Just for the lulz I also did it in C#:
{% highlight c# %}
public class Node
    {
        public string Value { get; set; }
        public Node Left { get; set; }
        public Node Right { get; set; }
        public Node(string val, Node left = null, Node right = null)
        {
            this.Value = val;
            this.Left = left;
            this.Right = right;
        }
    }
    public class SerializeDeserializeBinaryTree
    {
        public static string Serialize(Node input)
        {
            if(input == null) {
                return "@";
            }
            return input.Value + "," + Serialize(input.Left) + "," + Serialize(input.Right);
        }

        public static Node Deserialize(string input)
        {
            var arrInput = input.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            var iter = arrInput.GetEnumerator();
            iter.MoveNext();
            return DeserializeIn(iter);
        }
        private static Node DeserializeIn(IEnumerator en)
        {
            var currentValue = (string)en.Current;
            if(currentValue == "@") {
                return null;
            }
            var n = new Node(currentValue);
            en.MoveNext();
            n.Left = DeserializeIn(en);
            en.MoveNext();
            n.Right = DeserializeIn(en);
            return n;
        }
    }
{% endhighlight %}

### Explanation

Both cases use the same logic. The serialization part is done by recursively calling the same function and this is what it does:

* If the node is null, which would mean the previous node did not have children, we mark that with the '@' character, think of it as our EOL character.
* Otherwise, we return the node's value and then append the result of serializing its left and right children.

This has the less number of lines as navigating through the tree is fast this way and there is no need to check for many edge cases.

Deserialization is usually the fun part.

I did it by first preparing the nodes converting it to an array (or a List in the Python version) and then using an iterator to move one position at a time, remember how we did the serialization? One node at a time we evaluated the left and right nodes so the code for deserialization uses a similar logic:

* If the current element is our EOL character, we know this belong to a leaf in the node and it should be a null Node.
* Otherwise, we know the current element corresponds to a Node so we initialize it with its value and then use recursion to evaluate its Left and Right Nodes by moving the Iterator one slot at a time.

Profit!

I was thinking this was harder. I think the first time I saw this problem I probably messed up with conditions and failed to recognize that recursion was the way to go. I think I was trying to keep positions counted as to know if I was evaluating the left or right side of the tree? I can't remember but once I put a little thought in this everything is more clear.
One way to look at the use of recursion is that when adding a call to our call stack, we are actually queuing (names do not help, I know) which will then process our commands in the order we requested them. Stacks and Queues are tremendously important data structures to work with trees so it is good to review those.

Hope you liked this post and it is helpful for your own studies! I am working on something a little different too, kind of a pet project I want to publish, so you should be seeing something interesting coming up in the next posts. Stay tuned!


> Na lû e-govaned 'wîn
