--- 
title: Doing It Right ~ Getting Expanded File Path
date: 2010-10-20
category: ruby
tags: tips, ruby
---
This is dead simple, yet i never know it, till i saw the *.gemspec generated using
*'bundle gem'*:

    bundle gem blah

Cos i have never really taken a good look at the
[rdoc](http://www.ruby-doc.org/core/classes/File.html#M002540). Anyway, here's
the revised vesion of how i usually require files:

    @@ruby

    # Before :(
    require File.expand_path(File.join(File.dirname(__FILE__), 'somefile'))

    # After :)
    require File.expand_path('../somefile', __FILE__)

Short & sweet ?!
