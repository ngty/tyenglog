--- 
title: Getting a 1.9.*-ish Proc#source_location
date: 2010-09-20
category: ruby
tags: tips, ruby
---
Ruby 1.9.* comes with *Proc#source_location*, which according to the documentation,
returns the ruby source filename and line number containing this proc, or nil if
this proc was not defined in ruby (i.e. native):

    @@ruby

    prc.source_location
    # >> [String, Fixnum]

I've never wrote proc in native code, but from my experience while writing
[sourcify](http://github.com/ngty/sourcify), the procs derived from
*Method#to_proc* & *Symbol#to_proc* returns *Proc#source_location* as nil:

    @@ruby

    thing = Class.new {
      def test1(&block); block ; end
      def test2; end
      def test3; lambda{}; end
    }.new

    thing.method(:test1).to_proc.source_location
    # >> nil

    thing.test1(&:test2).source_location
    # >> nil

    thing.test3.source_location
    # >> ["/tmp/test.rb", 4]

If we wanna enhance 1.8.* & JRuby to support *Proc#source_location* (a bonus
provided by [sourcify](http://github.com/ngty/sourcify) in supporting
*Proc#to_source*), the fundamental approach is to use *Proc#inspect*:

    @@ruby

    proc = lambda{}
    inspect_str = proc.inspect
    # >> #<Proc:0x00007f53743f24a0@/tmp/test.rb:2>

    %r{^#<Proc:0x[0-9A-Fa-f]+@(.+):(\d+).*?>$}.match(inspect_str)[1..2]
    # >> ["/tmp/test.rb", "2"]

Thanks to ruby's open class support, we open up the *Proc* class to add the method:

    @@ruby

    class Proc
      # Honour the already implemented Proc#source_location
      unless lambda{}.respond_to?(:source_location)
        def source_location
          file, line = %r{^#<Proc:0x[0-9A-Fa-f]+@(.+):(\d+).*?>$}.match(inspect)[1..2]
          [file, line.to_i]
        end
      end
    end

Reusing the above derivation of *thing*, let's see if the home-baked *Proc#source_location*
behaves as expected:

    @@ruby

    # Nope, it doesn't :(
    thing.method(:test1).to_proc.source_location
    # Ruby-1.8.7  >> ["/tmp/test.rb", 2]
    # JRuby-1.5.2 >> ["/tmp/test.rb", 2]

    # Nope, it doesn't :(
    thing.test1(&:test2).source_location
    # Ruby-1.8.7  >> ["/tmp/test.rb", 7]
    # JRuby-1.5.2 >> ["/home/ty.archlinux/.rvm/rubies/jruby-1.5.2/lib/ruby/site_ruby/shared/builtin/core_ext/symbol.rb", 3]

    # Yup, it does :)
    thing.test3.source_location
    # Ruby-1.8.7  >> ["/tmp/test.rb", 12]
    # JRuby-1.5.2 >> ["/tmp/test.rb", 12]

For JRuby, *Symbol#to_proc* yields a proc with that originates from somewhere in JRuby's
core installation. For the case of JRuby, we can use this unique locator to achieve what
we have 1.9.*. But that ONLY solves half of the problem for JRuby, and non for Ruby-1.8.7.

In order to capture created-on-the-fly-ness of the proc, i introduced
Proc#created\_on\_the\_fly to store the flag, here's the solution i've used:

    @@ruby

    class Proc
      unless lambda{}.respond_to?(:source_location)

        def source_location
          # Only if proc is not created on the fly then we return meaningful source location
          unless created_on_the_fly
            file, line = %r{^#<Proc:0x[0-9A-Fa-f]+@(.+):(\d+).*?>$}.match(inspect)[1..2]
            [file, line.to_i]
          end
        end

        # Flag to capture if proc is created on the fly
        attr_accessor :created_on_the_fly

        [Method, Symbol].each do |klass|
          klass.class_eval do

            # Backup the original klass#to_proc
            alias_method :__pre_patched_to_proc, :to_proc

            def to_proc
              _proc = __pre_patched_to_proc   # get the original proc
              _proc.created_on_the_fly = true # manipulate the flag
              _proc
            end

          end
        end

      end
    end

Seeing is believing:

    @@ruby

    # Yup, it does :)
    thing.method(:test1).to_proc.source_location
    # Ruby-1.8.7  >> nil
    # JRuby-1.5.2 >> nil

    # Yup, it does :)
    thing.test1(&:test2).source_location
    # Ruby-1.8.7  >> nil
    # JRuby-1.5.2 >> nil

    # Yup, it does :)
    thing.test3.source_location
    # Ruby-1.8.7  >> ["/tmp/test.rb", 12]
    # JRuby-1.5.2 >> ["/tmp/test.rb", 12]

Does the above work for Ruby-1.8.6 ? Yup, but a little bit of tweaking of the above
solution is required. Anyway, the above is already implemented in
[sourcify](http://github.com/ngty/sourcify), do it check it out :]

