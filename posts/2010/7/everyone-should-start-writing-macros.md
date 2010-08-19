--- 
title: Everyone Should Start Writing Macros
date: 2010-07-22
category: ruby
tags: test
---
Did some cleaning & catching up of specs for
[railsbestpractices.com](http://rails-bestpractices.com) yesterday, added quite a
number of spec macros to dry up stuff, as well as cutting down the complexity within
the spec files. Personally, i really really & really like macros, because it is fun
to write &  easy to write, it has many beneficial side effects:

1. Since it is so simple to use macros, everyone in the team is more willing to
participate in spec writing. Personal experience has proven that if specs/tests
are hard to write, some developers tend to skip it.

2. Since it is so easy to read, maintenance becomes much easier

3. Developers are smart people (and should be paid well, but that's another story),
by replacing repeated copy & paste & minor edit-here-and-there with
macros-writing-and-usage, they feel smarter, a huge morale boast ~> happier team, &
when people are happy, they tend to show more love towards the project, take
ownership ~> project in a better state.

Btw, macro writing is no rocket-science, let's get started:

**1. Macro for 3rd party declarative**

Given the following model:

    @@ruby

    class User < ActiveRecord::Base
      acts_as_authentic
      # (blah blah)
    end

Ok, we all know that [authlogic](http://github.com/binarylogic/authlogic) is well tested,
so there is really no point in writing specs for it. Yet, how do we know the model is
pulling in authlogic support ?? Here's what i've done:

    @@ruby

    module RailsBestPractices
      module Macros

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods

          def should_act_as_authentic
            # Get most basic modules included by ActiveRecord::Base
            basic_included_modules = Class.new(ActiveRecord::Base).included_modules

            # Grab the model class
            model = description.split('::').inject(Object){|klass,const| klass.const_get(const) }

            # Get the extra modules included by the model
            model_included_modules = model.included_modules
            extra_modules = (model_included_modules - basic_included_modules).map(&:to_s)

            # As long as we have any extra module matching the regexp, we can conclude that
            # :acts_as_authentic has been declared for the model
            extra_modules.any?{|mod| mod =~ /Authlogic::ActsAsAuthentic::/ }.should be_true
          end

        end

      end
    end

The usage in the spec file is:

    @@ruby

    describe User do
      include RailsBestPractices::Macros
      should_act_as_authentic
      # (blah blah)
    end

Of course, i can probably remove the include  statement altogether & do the auto-including
elsewhere, but taking this route, other developers may throw
WTF\_IS\_SHOULD\_ACT\_AS\_AUTHENTIC\_ERROR ~> BAD BAD BAD !!

**2. Macro for project-specific declarative**

Given the following:

    @@ruby

    # Model
    class Post < ActiveRecord::Base
      include Markdownable
      # (blah blah)
    end

    # Mixin
    module Markdownable

      def self.included(base)
        base.class_eval do
          before_save :generate_formatted_html
        end
      end

      def generate_formatted_html
        self.formatted_html = RDiscount.new(body).to_html
      end

    end

I wanna make sure the support from the home-baked Markdownable is pulled in. Since it is home-baked,
just making sure the module is mixed in is not good enough, i need to ensure the functionality is
there as well, thus the macro definition:

    @@ruby

    def should_be_markdownable
      # Determine which factory to call
      factory_id = description.split('::').
        inject(Object){|klass, const| klass.const_get(const) }.
        to_s.tableize.singularize.to_sym

      # Generate an example group
      describe "being markdownable" do

        it "should generate simple markdown html" do
          raw = "subject\n=======\ntitle\n-----"
          formatted = "<h1>subject</h1>\n\n<h2>title</h2>\n"
          Factory(factory_id, :body => raw).formatted_html.should == formatted
        end

        it "should generate markdown html with <pre><code>" do
          raw = "subject\n=======\ntitle\n-----\n    def test\n      puts 'test'\n    end"
          formatted = "<h1>subject</h1>\n\n<h2>title</h2>\n\n" +
            "<pre><code>def test\n  puts 'test'\nend\n</code></pre>\n"
          Factory(factory_id, :body => raw).formatted_html.should == formatted
        end

      end
    end

And the usage:

    @@ruby

    describe Post do
      include RailsBestPractices::Macros
      should_be_markdownable
      # (blah blah)
    end

**3. Macro for any other vanilla functionality**

Given the following:

    @@ruby

    class Implementation < ActiveRecord::Base
      def belongs_to?(user)
        user && user_id == user.id
      end
    end

The macro definition:

    @@ruby

    def should_have_user_ownership
      factory_id = description.split('::').inject(Object){|klass,const| klass.const_get(const) }.
        to_s.tableize.singularize.to_sym

      describe 'having user ownership' do

        it 'should belong to someone if he is the owner of it' do
          someone = Factory(:user)
          Factory(factory_id, :user => someone).belongs_to?(someone).should be_true
        end

        it 'should not belong to someone if he is not the owner of it' do
          someone = Factory(:user)
          Factory(factory_id).belongs_to?(someone).should be_false
        end

      end
    end

Finally, the usage:

    @@ruby

    describe Implementation do
      include RailsBestPractices::Macros
      should_have_user_ownership
    end

Of course, it doesn't make sense to define macro for every functionality available. The general
thumb of rule is that when similar code appears more than once, u can consider defining a macro for
it. However, if similar-code is to appear more than once, u will probably start by extracting the
code & placing it inside a module (eg. Markdownable), so this probably falls under the 2nd case of
"Macro for project-specific declarative".

Last but not least, the above macro definition can probably benefit from some refactoring, but i
guess i'll leave this exercise to u :]
