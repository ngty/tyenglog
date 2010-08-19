--- 
title: Marshal/Unmarshal Problem with JRuby
date: 2010-07-15
category: ruby
tags: jruby, cross-stub, serializing, tips
---
While working on [cross-stub](http://github.com/ngty/cross-stub) today, ran into a
marshal/unmarshal problem with jruby, caused by binary string encoding issue. Anyway,
let's start by taking a look at some code:

    @@ruby

    time1 = Time.now
    time2 = Marshal.load(
      %|#{Marshal.dump(time1).gsub('|','\|')}|
    )

    puts time1 == time2

Here's what i got when running the above in different rubies:

    # Case 1: The expected output of Ruby 1.8.7 & Ruby 1.9.1 & Ree 1.8.7
    # >> true

Yet:

    # Case 2: The unexpected output of Jruby-1.5.1
    # >> (eval):1:in `_load': marshaled time format differ (TypeError)

Did quite abit of research, either my googling skill sucks, or nobody has the same problem
as me ... yet eventually found something at
[stackoverflow](http://stackoverflow.com/questions/1759371/how-do-i-unmarshal-a-ruby-object-in-java),
which lights up the bulb, & here's the amended code that works for all the above-mentioned rubies:

    @@ruby

    require 'base64'

    time1 = Time.now
    time2 = Marshal.load(
      Base64.decode64(
        %|#{Base64.encode64(Marshal.dump(time1)).gsub('|','\|')}|
    ))

    puts time1 == time2
