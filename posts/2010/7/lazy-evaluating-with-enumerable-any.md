--- 
title: Lazy evaluating with Enumerable#Any
date: 2010-07-28
category: ruby
tags: tips
---
Most of us know this:

    @@ruby

    class Awesome
      def self.m1 ; true            ; end
      def self.m2 ; raise Exception ; end
    end

    # Case 1:
    Awesome.m1 or Awesome.m2
    # >> no error thrown

For some of us who likes *Enumerable#any?*, this won't work:

    @@ruby

    # Case 2:
    [Awesome.m1, Awesome.m2].any?
    # >> error thrown

That is because *m1* & *m2* are already evaluated before calling *Enumerable#any?*,
to have lazy evaluation, we can do this:

    @@ruby

    # Case 3:
    [:m1, :m2].any?{|m| Awesome.send(m) }
    # >> no error thrown

For the perversive ones:

    @@ruby

    # Case 4:
    Awesome.instance_exec { [:m1, :m2].any?{|m| send(m) } }
    # >> no error thrown

Abit too far ? I guess case#1 is good enough for this particular example.
