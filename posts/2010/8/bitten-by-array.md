---
title: Bitten by Array#*
date: 2010-08-04
category: ruby
tags: tips
---
Have u tried *Array#** ? Its a pretty cool way to return an array, built by concatenating
the original array by n times:

    @@ruby

    a = [1] * 2
    p a # >> [1, 1]

    a = %w{a} * 2
    p a # >> ["a", "a"]

However, u should be aware that all elements of the new array actually points to the same
instance, as proven by their *object_id*:

    @@ruby

    x = 'a'
    p x.object_id # >> 70212363949780

    a = [x] * 2
    p a.map(&:object_id) # >> [70212363949780, 70212363949780]

This means that reassigning one element does not affect another:

    @@ruby

    a = %w{a} * 2
    p a.map(&:object_id) # >> [70058328018360, 70058328018360]
    a[0] = a[0].sub('a','b')
    p a # >> ["b", "a"]
    p a.map(&:object_id) # >> [69915340242120, 69915340242360]

Yet in-place manipulating (with *!*) one element affects another:

    @@ruby

    a = %w{a} * 2
    p a.map(&:object_id) # >> [70058328018360, 70058328018360]
    a[0].sub!('a','b')
    p a # >> ["b", "b"]
    p a.map(&:object_id) # >> [70058328018360, 70058328018360]
