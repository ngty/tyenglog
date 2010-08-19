--- 
title: Relatively Unknown Object#instance_exec
date: 2010-07-21
category: ruby
tags: tip
---
Do u happen to know *Object#instance_eval*'s brother, *Object#instance_exec* ??
Here's an uninteresting way of coding wo *Object#instance_exec*:

    @@ruby

    Someone = Struct.new(:name, :password)

    greet = lambda do |someone|
      puts "Hey %s, no worries, i won't tell anyone ur password is '%s' !!" %
        [someone.name, someone.password]
    end

    greet[Someone.new('Peter', 'aabbcc')]
    # >> Hey Peter, no worries, i won't tell anyone ur password is 'aabbcc' !!

    greet[Someone.new('Jane', 'bbccdd')]
    # >> Hey Jane, no worries, i won't tell anyone ur password is 'bbccdd' !!

Using the same class *Someone*, here's a more interesting way to do it, w
*Object#instance_exec*:

    @@ruby

    greet = lambda do
      puts "Hey %s, no worries, i won't tell anyone ur password is '%s' !!" %
        [name, password]
    end

    Someone.new('Peter', 'aabbcc').instance_exec(&greet)
    # >> Hey Peter, no worries, i won't tell anyone ur password is 'aabbcc' !!

    Someone.new('Jane', 'bbccdd').instance_exec(&greet)
    # >> Hey Jane, no worries, i won't tell anyone ur password is 'bbccdd' !!

Yet another way to do it can be:

    @@ruby

    greet = lambda{|msg| puts msg % [name, password] }

    Someone.new('Peter', 'aabbcc').instance_exec \
      "Hey %s, no worries, i won't tell anyone ur password is '%s' !!", &greet
    # >> Hey Peter, no worries, i won't tell anyone ur password is 'aabbcc' !!

    Someone.new('Jane', 'bbccdd').instance_exec \
      "Hey %s, i'm glad that u entrust me with ur password '%s' !!", &greet
    # >> Hey Jane, i'm glad that u entrust me with ur password 'bbccdd' !!

Nice ?
