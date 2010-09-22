--- 
title: How to Test IRB Specific Support ?
date: 2010-09-22
category: ruby
tags: tips, ruby, irb
---
Yippie, [Sourcify](http://github.com/ngty/sourcify) is going to support *Proc#to_source*
even in IRB !! Yup, many thanks to [@alexch](http://github.com/alexch) &
[Florian Groß's RubyQuiz SerializableProc solution](http://rubyquiz.com/quiz38.html).
BUT, how the hell am i supposed to test this IRB-specific support ?

Here's my preliminary hackish take (until i can think of a better approach):

    @@ruby

    def irb_exec(stdin_str = '')
      require 'tempfile'
      tf = Tempfile.new(nil) # get a unique tmp file (what we really want is the path)

      begin
        $o_stdin, $o_stdout = $stdin, $stdout # Backup the existing stdin/stdout
        $stdin, $stdout = File.new(tf.path + '~stdin','w+'), File.new(tf.path + '~stdout','w+')
        $stdin.puts [stdin_str, 'exit', ''].join("\n")
        $stdin.rewind

        require 'irb'
        IRB.start

        $stdout.rewind
        $stdout.readlines.join
      ensure
        [$stdin, $stdout, tf].each{|f| File.delete(f.path) }
        $stdin, $stdout = $o_stdin, $o_stdout
      end
    end

Setting *$stdin* & *$stdout* as instances of *File* instead of *Tempfile* may seem a less than
optimal approach, i must agree on it, in fact, what i really wanted to use in the 1st place
is *StringIO* ... BUT, *IRB* enforces the usage of *File*.

OKKO, since seeing is believing, let's try it out:

    @@ruby

    irb_exec("%w{a b c}.join")
    # >> "ruby-1.8.7-p302 > %w{a b c}.join\n => \"abc\" \nruby-1.8.7-p302 > exit\n"

Can we do better ?! Sure, let's make sure we only retrieve those lines with prepending ' => ',
cos those lines actually represent the irb feedback for code we pass in. Here's the revised
version (note changes in lines 15 & 16, plus drying up 7):

    @@ruby

    def irb_exec(stdin_str = '')
      require 'tempfile'
      tf = Tempfile.new(nil) # get a unique tmp file (what we really want is the path)

      begin
        $o_stdin, $o_stdout = $stdin, $stdout # Backup the existing stdin/stdout
        $stdin, $stdout = %w{in out}.map{|s| File.new("#{tf.path}~std#{s}",'w+') }
        $stdin.puts [stdin_str, 'exit', ''].join("\n")
        $stdin.rewind

        require 'irb'
        IRB.start

        $stdout.rewind
        irb_feedback = /^ => / # irb feedback string looks like this
        $stdout.readlines.join.split("\n").grep(irb_feedback).
          map{|s| eval(s.sub(irb_feedback,'').strip) } # use eval to get actual return value
      ensure
        [$stdin, $stdout, tf].each{|f| File.delete(f.path) }
        $stdin, $stdout = $o_stdin, $o_stdout
      end
    end

Note that in line 17, i use eval to get the actual return value, instead of the inspected one.
As usual, seeing is believing:

    @@ruby

    irb_exec("%w{a b c}.join")
    # >> ["abc"]

BUT BUT, the above only works if u run *irb_exec* ONCE per process:

    @@ruby

    # OK for the 1st run
    irb_exec("%w{a b c}.join")
    # >> ["abc"]

    # Yikes, subsequent runs fail !!
    irb_exec("%w{a b c}.join")
    # >> /home/ty.archlinux/.rvm/rubies/ruby-1.8.7-p302/lib/ruby/1.8/e2mmap.rb:152: warning: already initialized constant UnrecognizedSwitch
    # >> /home/ty.archlinux/.rvm/rubies/ruby-1.8.7-p302/lib/ruby/1.8/e2mmap.rb:152: warning: already initialized constant NotImplementedError
    # >> /home/ty.archlinux/.rvm/rubies/ruby-1.8.7-p302/lib/ruby/1.8/e2mmap.rb:152: warning: already initialized constant CantReturnToNormalMode
    # >> /home/ty.archlinux/.rvm/rubies/ruby-1.8.7-p302/lib/ruby/1.8/e2mmap.rb:152: warning: already initialized constant IllegalParameter
    # >> /home/ty.archlinux/.rvm/rubies/ruby-1.8.7-p302/lib/ruby/1.8/e2mmap.rb:152: warning: already initialized constant IrbAlreadyDead
    # >> /home/ty.archlinux/.rvm/rubies/ruby-1.8.7-p302/lib/ruby/1.8/e2mmap.rb:152: warning: already initialized constant IrbSwitchedToCurrentThread
    # >> /home/ty.archlinux/.rvm/rubies/ruby-1.8.7-p302/lib/ruby/1.8/e2mmap.rb:152: warning: already initialized constant NoSuchJob
    # >> /home/ty.archlinux/.rvm/rubies/ruby-1.8.7-p302/lib/ruby/1.8/e2mmap.rb:152: warning: already initialized constant CantShiftToMultiIrbMode
    # >> /home/ty.archlinux/.rvm/rubies/ruby-1.8.7-p302/lib/ruby/1.8/e2mmap.rb:152: warning: already initialized constant CantChangeBinding
    # >> /home/ty.archlinux/.rvm/rubies/ruby-1.8.7-p302/lib/ruby/1.8/e2mmap.rb:152: warning: already initialized constant UndefinedPromptMode
    # >> []

Implementing fix for the already initialized constant thingy is simple, the real headache
is the empty return. Since *IRB.start* works as expected the 1st time per process, my
logical deduction is that the solution should meet this criterion, no matter how. Time to
use [Otaku](http://github.com/ngty/otaku), here's the revised *irb_exec*:

    @@ruby

    def irb_exec(stdin_str)
      require 'otaku'

      begin
        # This will start an evented server in another process, the server will execute the
        # enclosed code block when client requests come in.
        Otaku.start do |data|

          # Otaku takes a SerializableProc (see http://github.com/ngty/serializable_proc), &
          # by default, all variables are isolated, we don't want any for this particular case
          @@_not_isolated_vars = :all

          # Get a unique tmp file (what we really want is the path)
          require 'tempfile'
          tf = Tempfile.new('otaku')

          begin
            $o_stdin, $o_stdout = $stdin, $stdout # Backup the existing stdin/stdout
            $stdin, $stdout = %w{in out}.map{|s| File.new("#{tf.path}~std#{s}",'w+') }
            $stdin.puts [data, 'exit', ''].join("\n")
            $stdin.rewind

            require 'irb'
            ARGV.clear # Need this to prevent IRB from blowing up
            IRB.start(__FILE__)

            $stdout.rewind
            irb_feedback = /^ => / # irb feedback string looks like this
            $stdout.readlines.join.split("\n").
              grep(irb_feedback).map{|s| eval(s.sub(irb_feedback,'').strip) }
          ensure
            [$stdin, $stdout, tf].each{|f| File.delete(f.path) }
            $stdin, $stdout = $o_stdin, $o_stdout
          end
        end

        # This sends a client request to the above server
        Otaku.process(stdin_str)

      ensure
        # Since we can only IRB.start per process, we must kill otaku before this
        # method returns
        Otaku.stop
      end
    end

Finally, seeing is believing:

    @@ruby

    irb_exec('%w{a b}') # >> [["a", "b"]]
    irb_exec('%w{a b}') # >> [["a", "b"]]

I must admit using otaku really complicates the testing, and also slows down the run,
as additional time is needed to start the otaku server in another process. Yet, unless
there is a workaround to ensure *IRB.start* behaves when called multiple times per process,
this tradeoff is unavoidable.

Let me know if there is a better approach, ok ?!
