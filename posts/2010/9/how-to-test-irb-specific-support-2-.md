--- 
title: How to Test IRB Specific Support (2) ?
date: 2010-09-25
category: ruby
tags: tips, ruby, irb
---
This is a quick follow-up of the original
[*How to Test IRB Specific Support ?*](/2010/9/how-to-test-irb-specific-support).
If u don't mind shelling out stuff:

    @@ruby

    def irb_exec(code)
      irb_feedback = /^ => /
      %x(echo "#{code}" | irb -r lib/sourcify.rb).split("\n").
        grep(irb_feedback).map{|s| eval(s.sub(irb_feedback,'').strip) }
    end

Note that i pass *'-r lib/sourcify.rb'* to irb cos i'm testing against the sourcify
in development. This gets exactly the same result as the original approach, but is
alot more straight-forward & runs alot faster as well.

Many thanks to [@alexch](http://github.com/alexch) for mentioning it :]
