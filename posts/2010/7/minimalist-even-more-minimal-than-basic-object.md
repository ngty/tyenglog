--- 
title: Minimalist ... Even More Minimal than BasicObject
date: 2010-07-14
category: ruby
tags: cross-stub, tips
---
In [cross-stub](http://github.com/ngty/cross-stub), it is possible to declare stubs
using a proc:

    @@ruby

    Someone.xstub do
      def say(something)
        'saying "%s"' % something
      end
    end

Implementation wise, i need a way to find out the methods delared within the proc
in order to do further processing. The most straight-forward way is to have a bare
minimum object, after *Proc#instance_eval*, do a diff of the original set of
instance methods & the set of methods for this manipulated object. The following
illustrates the concept:

    @@ruby

    (minimalist = Minimalist.new).instance_eval(&block)
    minimalist.methods - Minimalist.instance_methods

Well, i've in fact considered using *BasicObject*, but then, it doesn't appear to
be as basic as i hope it should it. Thus i decided to handroll my own *Minimalist*
solution:

    @@ruby

    class Minimalist
      alias_method :__instance_eval__, :instance_eval
      alias_method :__methods__, :methods
      instance_methods.each{|meth| undef_method(meth) if meth.to_s !~ /^__.*?__$/ }
    end

As u can see (in order to prevent any methods clash with
user-defined-to-be-stubbed-methods) what i've done is just:

1. renaming instance\_eval & methods to the more cryptic \_\_instance_eval\_\_ &
\_\_methods\_\_, and
2. undefining all methods, except those with prepending & appending '__'

It works well in ruby-1.8.7, but then, running the above in ruby-1.9.1 displays the
following warning:

    warning: undefining `object_id' may cause serious problem

With the solution suggested in this [discussion](http://www.ruby-forum.com/topic/127608),
*Minimalist* is revised to:

    @@ruby

    class Minimalist
      alias_method :__instance_eval__, :instance_eval
      alias_method :__methods__, :methods
      $VERBOSE = nil
      instance_methods.each{|meth| undef_method(meth) if meth.to_s !~ /^__.*?__$/ }
      $VERBOSE = true
    end

Now the warning doesn't show. Yet in ruby-1.8.7, i got plenty of eval warnings:

    (eval):1: warning: discarding old say
    (eval):1: warning: discarding old say
    (eval):1: warning: method redefined; discarding old bang

Hmmm ... undaunted, i got this final version of Minimalist:

    @@ruby

    class Minimalist
      alias_method :__instance_eval__, :instance_eval
      alias_method :__methods__, :methods
      orig_verbosity, $VERBOSE = $VERBOSE, nil
      instance_methods.each{|meth| undef_method(meth) if meth.to_s !~ /^__.*?__$/ }
      $VERBOSE = orig_verbosity
    end

Happy ever after? Nope, in jruby-1.5.1, i got:

    warning: `instance_eval' should not be aliased

The final final final (i promise) Minimalist becomes:

    @@ruby

    class Minimalist
      orig_verbosity, $VERBOSE = $VERBOSE, nil
      # (method aliasing & removal stays here)
      $VERBOSE = orig_verbosity
    end

PHEW !!
