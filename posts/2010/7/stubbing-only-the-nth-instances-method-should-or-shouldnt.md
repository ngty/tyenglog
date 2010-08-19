--- 
title: Stubbing Only the Nth Instance's Method, Should or Shouldn't ?
date: 2010-07-21
category: ruby
tags: test, design, cross-stub
---
A few days back, [cross-stub](http://github.com/ngty/cross-stub)  version 0.2.0 has been
released, with this release, cross process instance method stubbing is now possible.
While doing review of [zan's work](http://github.com/ngty/cross-stub/tree/dev), we've
discussed the possibility of having more control on which exact instance the stub should
be applied to, as illustrated below:

    @@ruby

    Time.xstub(:day, :instance => 1)    # applies to ONLY 1st Time instance
    Time.xstub(:day, :instance => 2..3) # applies to ONLY 2nd ~ 3rd Time instances

Initially, i was quite happy to have brought up this. But after some thinking, i'm convinced
that this a LOUSY idea, as it requires the user to have intimate knowledge of how many times
a class's instance have been created, which can be tedious (if not impossible) if the
instance method is provided by ruby core/std libs, or popular gems. It also results in
extremely brittle tests, as nth can easily beconme xth, or zth ...

I think the issue is very fundamental, it goes down to how the code is written. Given the
following example:

    @@ruby

    class Papa
      def free_today?
        # Any papa is free on weekend but not weekday
        !Time.now.strftime('%w').between?(0,5)
      end
    end

    class Mama
      def free_today?
        # Any mama is free on weekday but not weekend
        Time.now.strftime('%w').between?(0,5)
      end
    end

If i were to apply stubbing for *Time#strftime*, i would affect both i*Papa#free_today?* &
*Mama#free_today?*. Taking one step back, if we to affect only *Papa#free_today?*, we need
to consider the context where the *Time#strftime* stub is-to-be applied, & do the following
revision:

    @@ruby

    class Papa

      def free_today?
        !today_dow.between?(0,5)
      end

      def today_dow
        Time.now.strftime('%w')
      end

    end

    class Mama

      def free_today?
        today_dow.between?(0,5)
      end

      def today_dow
        Time.now.strftime('%w')
      end

    end


Therefore, by stubbing *Papa#today_dow*, we won't affect *Mama#free_today?*. Moreover, taking
this approach gives us the chance to do some cleaning up:

    @@ruby

    class Parent
      def today_dow
        Time.now.strftime('%w')
      end
    end

    class Papa < Parent
      def free_today?
        !today_dow.between?(0,5)
      end
    end

    class Mama < Parent
      def free_today?
        today_dow.between?(0,5)
      end
    end

Imagine if we go the other approach of doing nth instance's method stubbing, though feasible,
the test will be extremely brittle (nightmarish maintenance), as nth can easily be changed
to xth, or zth.

CONCLUSION: No, we don't need better control over nth instance's method stubbing, cross-stub's
instance method stubbing is going to remain as it is. If u need it, drop me a mail with an
example to justify the need :]
