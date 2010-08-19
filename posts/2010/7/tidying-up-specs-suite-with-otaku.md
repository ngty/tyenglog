--- 
title: Tidying Up Specs Suite with Otaku
date: 2010-07-18
category: ruby
tags: test, cross-stub, otaku
---
In the specs suite of [cross-stub](http://github.com/ngty/cross-stub), i've built a custom
echo server using [this approach](/2010/7/building-a-simple-server-client-with-eventmachine)
to support testing of stubbing in another process. Nothing wrong with it, except that it is
not so fun & clean. Anyway, over the weekend, i've extracted out the echo server code, and
put it inside a new & fun project [otaku](http://github.com/ngty/otaku).

Here's my tidied up specs (which serve as a good example usage of otaku):

    @@ruby

    shared 'has other process setup' do

      behaves_like 'has standard setup'

      before do
        # Don't start the service if it has already been started.
        $service_started ||= (
          Otaku.start do |data|

          # Pull in all the helpers, __FILE__ magically converts to path of this file,
          # even after otaku's internal marshalling/unmarshalling.
          require File.join(File.dirname(__FILE__), '..', 'includes')

          # Some processing ... using helpers & class definitions pulled in by the above
          # require statement.
          store_type, method_call_args = data.match(/^(.*?)\/(.*)$/)[1..2]
          CrossStub.refresh(cache_store($prev_store_type)) if $prev_store_type
          CrossStub.refresh(cache_store($prev_store_type = store_type))

          # Actually capturing of error is not necessary, cos Otaku captures any error &
          # wrap it up in Otaku::DataProcessError.
          do_local_method_call(method_call_args) rescue $!.message
          end

        true
        )
      end

    end

    at_exit do
      # Stops otaku if it has been started, only this process is abt to exit.
      $service_started && Otaku.stop
    end

