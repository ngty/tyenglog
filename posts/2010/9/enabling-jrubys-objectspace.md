--- 
title: Enabling JRuby's ObjectSpace
date: 2010-09-09
category: ruby
tags: tips, jruby
---
In testing how well [sourcify](http://github.com/ngty/sourcify) can handle codes in the
wild, i need a way to collect all procs from the ObjectSpace, and check if *Proc#to_source*
works as expected. Yet, JRuby's ObjectSpace is turned off by default to avoid
[unnecessary creating of extra objects](http://kenai.com/projects/jruby/pages/PerformanceTuning#Disabling_ObjectSpace).

To turn it on at script level:

    @@ruby
    require 'jruby'
    JRuby.objectspace = true

Alternatively, to turn it on per-process:

    $ rvm use jruby
    $ ruby -X+O -S irb
