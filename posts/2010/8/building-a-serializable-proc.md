---
title: Building a Serializable Proc
date: 2010-08-20
category: ruby
tags: tips, serializable_proc
---
Hey, let's build a serializable proc today !! But before we do that, let's 1st define
what is a serializable proc. A serializable proc differs from a vanilla proc in 2 ways:

**1. Isolated Variables**

Variables within the proc can be completely isolated from the surrounding context, thus
achieving some sort of snapshot effect:

    @@ruby

    require 'rubygems'
    require 'serializable_proc'

    x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'

    s_proc = SerializableProc.new { [x, @x, @@x, $x].join(', ') }
    v_proc = Proc.new { [x, @x, @@x, $x].join(', ') }

    x, @x, @@x, $x = 'ly', 'iy', 'cy', 'gy'

    s_proc.call # >> "lx, ix, cx, gx"
    v_proc.call # >> "ly, iy, cy, gy"

**2. Marshallable**

No throwing of TypeError when marshalling a SerializableProc:

    @@ruby

    Marshal.load(Marshal.dump(s_proc)).call # >> "lx, ix, cx, gx"
    Marshal.load(Marshal.dump(v_proc)).call # >> TypeError (cannot dump Proc)

<br/>
As u may have already know, a proc is a closure, and a closure consists of a code-block &
binding (a scope environment with variables). In order to acheive what we have describe
above, we need to extract:

1. the code-block &
2. the bounded variables

Let's get started with the simplier one, which is extracting the code-block, but before we
get started, we have to install some pre-requisites:

    $ gem install ParseTree ruby2ruby

Yup, that's all we need .. huh, u are on a ruby version/platform (eg. 1.9.* & JRuby) that
doesn't support ParseTree, no prob, that can be tackled, but it is going to be more
complicated (probably not within this post), so let's KISS ?

**1. Extracting the Code**

This is really simple with ParseTree:

    @@ruby

    require 'pp'
    require 'ruby2ruby'
    require 'parse_tree'
    require 'parse_tree_extensions'

    x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
    s_proc = lambda { [x, @x, @@x, $x] }
    e_code = s_proc.to_ruby
    pp e_code # >> "proc { [x, @x, @@x, $x] }"

I really love ParseTree for making it so simple to extract a piece of ruby code, and it is
a real pity that it doesn't run on 1.9.* & JRuby.

**2. Extracting Bounded Variables**

To extract bounded variables, we need to know what to extract in the 1st place. Just by
inspect the above *e_code* is doable, but can present quite a number of problems, how do
we know *x* is a method call, or a variable. This turns out to be very easy if we inspect
the extracted sexp
([see this post for more info abt sexp](http://blog.rubybestpractices.com/posts/judofyr/sexp-for-rubyists.html))
instead:

    @@ruby

    e_sexp = s_proc.to_sexp
    pp e_sexp
    # >> s(:iter,
    # >>  s(:call, nil, :proc, s(:arglist)),
    # >>   nil,
    # >>   s(:array, s(:lvar, :x), s(:ivar, :@x), s(:cvar, :@@x), s(:gvar, :$x)))

To extract the variables we want, we are concerned with with the following occurrences:

    s(:lvar, :*)
    s(:ivar, :*)
    s(:cvar, :*)
    s(:gvar, :*)

The '*'s can be easily extracted with some regexp:

    @@ruby

    pattern, e_names = /s\(:(?:l|i|c|g)var,\ :((?:|@|@@|\$)(?:\w+))\)/, []
    e_sexp.inspect.gsub(pattern){|s| e_names << s.sub(pattern,'\1') }
    pp e_names # >> ["x", "@x", "@@x", "$x"]

Together with *Proc#binding*:

    @@ruby

    s_binding = s_proc.binding
    e_vars = e_names.inject({}) do |memo, name|
      memo.merge(:"#{name}" => binding.eval(name))
    end
    pp e_vars # >> {:$x=>"gx", :@x=>"ix", :x=>"lx", :@@x=>"cx"}

Since we want to isolate the variables, we need to slightly tweak the above snippet to do
a deep-copy of variables:

    e_vars = e_names.inject({}) do |memo, name|
      memo.merge(:"#{name}" => Marshal.load(Marshal.dump(binding.eval(name))))
    end

The above will fail when a variable cannot be marshalled, eg. instances of IO. That will be
tackled eventually, but not now (again KISSing in action).

**3. Putting the Pieces Together**

So far so good, let's put the separate pieces together in order to have a Proc-like class in
*serializable_proc.rb*:

    @@ruby

    require 'rubygems'
    require 'ruby2ruby'
    require 'parse_tree'
    require 'parse_tree_extensions'

    class SerializableProc

      def initialize(&block)
        @code = block.to_ruby
        @vars = grab_bounded_vars(block.to_sexp, block.binding)
      end

      def call(*args) # **(new)**
        # Since code is a string, we eval it to turn it into a Proc, with the
        # returned value from #binding
        eval(@code, binding).call(*args)
      end

      alias_method :[], :call

      private

        def binding # **(new)**
          # In essence, we are just doing the following here:
          # 1. get Kernel.binding
          # 2. load it with variables that we have extracted,
          # 3. return the loaded binding
          set_vars = @vars.map do |var, val|
            "#{var} = Marshal.load(%|#{Marshal.dump(val).gsub('|','\|')}|)"
          end.join('; ')
          (binding = Kernel.binding).eval(set_vars)
          binding
        end

        def grab_bounded_vars(sexp, binding)
          names, pattern = [], /s\(:(?:l|i|c|g)var,\ :((?:|@|@@|\$)(?:\w+))\)/
          sexp.inspect.gsub(pattern){|s| names << s.sub(pattern,'\1') }
          names.inject({}) do |memo, name|
            memo.merge(:"#{name}" => Marshal.load(Marshal.dump(binding.eval(name))))
          end
        end

    end

(notice that we have added 2 new methods, *#call* (alias *#[]*) & *#binding*)

Let's try out to see if things work:

    @@ruby

    x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
    s_proc = SerializableProc.new { [x, @x, @@x, $x] }
    pp s_proc.call # >> ["lx", "ix", "cx", "gx"]

Yup, preliminary test is ok, how abt checking if isolation is working ?

    @@ruby

    x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
    s_proc = SerializableProc.new { [x, @x, @@x, $x] }

    x, @x, @@x, $x = 'ly', 'iy', 'cy', 'gy'
    pp s_proc.call      # >> ["lx", "ix", "cx", "gx"] ... Pass :)
    pp [x, @x, @@x, $x] # >> ["ly", "iy", "cx", "gx"] ... Fail :(

It turns out that the local & instance vars are isolated as expected, yet the
class & global vars aren't ... somehow, whatever happens inside
*SerializableProc#binding* is affecting the outer context's class & global vars.
In order to achieve true isolation, we need to do extra work to convert all vars
to local vars, just start with code extraction.

**R1. Extracting the Code (Revised)**

Since we need to convert all variables to local variables, we can no longer use
the convenient *Proc#to_ruby* offered by ParseTree extensions, we need to manipulate
the extracted sexp by doing the necessary substitutions within:

    @@ruby

    x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
    s_proc = lambda{ [x, @x, @@x, $x] }
    e_sexp_str = s_proc.to_sexp.inspect
    n_sexp_str = ''

    while m = e_sexp_str.match(/^((.*?s\(:)(l|i|c|g)(var,\ :)(?:|@|@@|\$)((?:\w+)\)))/)
      original, part1, type, part2, part3 = m[1..5]
      n_sexp_str += part1 + 'l' + part2 + type + 'var_' + part3
      e_sexp_str.sub!(original, '')
    end

    n_sexp = eval(n_sexp_str += e_sexp_str)
    pp n_sexp
    # >> s(:iter,
    # >>  s(:call, nil, :proc, s(:arglist)),
    # >>  nil,
    # >>   s(:array,
    # >>    s(:lvar, :lvar_x),
    # >>    s(:lvar, :ivar_x),
    # >>    s(:lvar, :cvar_x),
    # >>    s(:lvar, :gvar_x)))

    n_code = Ruby2Ruby.new.process(n_sexp)
    pp n_code # >> "proc { [lvar_x, ivar_x, cvar_x, gvar_x] }"

**R2. Extracting Bounded Variables (Revised)**

We need to change the keys in the extracted vars hash as well:

    @@ruby

    pattern, e_names = /s\(:((?:l|i|c|g)var),\ :((?:|@|@@|\$)(\w+))\)/, []
    s_proc.to_sexp.inspect.gsub(pattern) do |s|
      m = s.match(pattern)[1..3]
      e_names << [m[1], m[0] + '_' + m[2]]
    end
    pp e_names
    # >> [["x", "lvar_x"], ["@x", "ivar_x"], ["@@x", "cvar_x"], ["$x", "gvar_x"]]

    binding = s_proc.binding
    n_vars = e_names.inject({}) do |memo, (o_name, n_name)|
      memo.merge(:"#{n_name}" => Marshal.load(Marshal.dump(binding.eval(o_name))))
    end
    pp n_vars
    # >> {:lvar_x=>"lx", :ivar_x=>"ix", :cvar_x=>"cx", :gvar_x=>"gx"}

**R3. Putting the Pieces Together (Revised)**

Let's revised our previous implementation of *SerializableProc* to reflect the above
changes:

    @@ruby

    require 'rubygems'
    require 'ruby2ruby'
    require 'parse_tree'
    require 'parse_tree_extensions'

    class SerializableProc

      def initialize(&block) # **(revised)**
        @code = grab_code(block.to_sexp)
        @vars = grab_bounded_vars(block.to_sexp, block.binding)
      end

      def call(*args)
        eval(@code, binding).call(*args)
      end

      alias_method :[], :call

      private

        def grab_code(sexp) # **(new)**
          n_sexp_str, o_sexp_str = '', sexp.inspect
          while m = o_sexp_str.match(/^((.*?s\(:)(l|i|c|g)(var,\ :)(?:|@|@@|\$)((?:\w+)\)))/)
            original, part1, type, part2, part3 = m[1..5]
            n_sexp_str += part1 + 'l' + part2 + type + 'var_' + part3
            o_sexp_str.sub!(original, '')
          end
          Ruby2Ruby.new.process(eval(n_sexp_str += o_sexp_str))
        end

        def grab_bounded_vars(sexp, binding) # **(revised)**
          names, pattern = [], /s\(:((?:l|i|c|g)var),\ :((?:|@|@@|\$)(\w+))\)/
          sexp.inspect.gsub(pattern) do |s|
            m = s.match(pattern)[1..3]
            names << [m[1], m[0] + '_' + m[2]]
          end
          names.inject({}) do |memo, (o_name, n_name)|
            memo.merge(:"#{n_name}" => Marshal.load(Marshal.dump(binding.eval(o_name))))
          end
        end

        def binding
          set_vars = @vars.map do |var, val|
            "#{var} = Marshal.load(%|#{Marshal.dump(val).gsub('|','\|')}|)"
          end.join('; ')
          (binding = Kernel.binding).eval(set_vars)
          binding
        end

    end

And the final test for variables isolation:

    @@ruby

    x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
    s_proc = SerializableProc.new { [x, @x, @@x, $x] }

    x, @x, @@x, $x = 'ly', 'iy', 'cy', 'gy'
    pp s_proc.call      # >> ["lx", "ix", "cx", "gx"] ... Pass :)
    pp [x, @x, @@x, $x] # >> ["ly", "iy", "cy", "gy"] ... Pass :)

<br/>
Simple rite ? Before we call it a day, let's make *SerializableProc* even more
pleasant to use, such that we can have:

    @@ruby

    def work(&block)
      yield
    end

    s_proc = SerializableProc.new { puts 'hello' }
    work(&s_proc) # >> "hello"

A pretty reasonable request rite ? Ok, let's fulfill it:

    @@ruby

    class SerializableProc

      # (blah blah .. old stuff)

      def to_proc
        eval(@code, binding)
      end

      def call(*args)
        to_proc.call(*args)
      end

    end

<br/>
Yup, i guess that's all for this post, btw, SerializableProc has already been
written & implemented,
[check it out at github](http://github.com/ngty/serializable_proc).
