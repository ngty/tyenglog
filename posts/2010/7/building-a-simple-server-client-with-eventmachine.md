--- 
title: Building a Simple Server/Client with Eventmachine
date: 2010-07-15
category: ruby
tags: eventmachine, cross-stub
---
In writing [cross-stub](http://github.com/ngty/cross-stub), i need to write specs to
ensure cross process stubbing indeed work as expected. This is achieved by building a
simple server/client using eventmachine, here's how *echo_server.rb* looks like:

    @@ruby

    require 'rubygems'
    require 'eventmachine'
    require 'logger'
    require 'base64'

    module EchoServer

      ADDRESS = '127.0.0.1'
      PORT = 10999
      LOG_FILE = '/tmp/echo_server.log'
      INIT_WAIT_TIME = 2 # may need to increase this depending on how slow is ur machine

      class << self

        def log(*msg)
          (@logger ||= Logger.new(LOG_FILE)) << [msg, ""].flatten.join("\n")
        end

        def cleanup
          @logger.close
        end

        def start(other_process=false)
          unless other_process
            print 'Starting echo service ... '
            @process = IO.popen("ruby #{__FILE__}",'r')
            sleep INIT_WAIT_TIME
            puts 'done (pid#%s)' % @process.pid
          else
            log 'Echo service (pid#%s) listening at %s:%s' % [Process.pid, ADDRESS, PORT]
            EventMachine::run { EventMachine::start_server(ADDRESS, PORT, EM) }
          end
        end

        def stop
          Process.kill('SIGHUP', @process.pid) if @process
        end

      end

      private

      module EM

        def receive_data(data)
          log 'Received client data: %s' % data.inspect
          result = process_data(data)
          log 'Processed to yield result: %s' % result.inspect
          send_data(Base64.encode64(Marshal.dump(result)))
        end

        def process_data(data)
          # do some meaningful processing to yield result
          result = '~ processed %s ~ ' % data
        end

        def log(*msg)
          EchoServer.log(*msg)
        end

      end

    end

    if $0 == __FILE__
      begin
        EchoServer.start(true)
      rescue
        EchoServer.log "#{$!.inspect}\n"
      ensure
        EchoServer.cleanup
      end
    end

And *echo_client.rb*:

    @@ruby

    # Keeping things DRY, avoid repeated typing of requiring statements &
    # server specific info (eg. address & port)
    require File.join(File.dirname(__FILE__), 'echo_server')

    module EchoClient

      ADDRESS = EchoServer::ADDRESS
      PORT = EchoServer::PORT

      class << self
        def get(data)
          EventMachine::run do
            EventMachine::connect(ADDRESS, PORT, EM).execute(data) do |data|
              @result = Marshal.load(Base64.decode64(data))
            end
          end
          @result
        end
      end

      private

      module EM

        def receive_data(data)
          @callback.call(data)
          EventMachine::stop_event_loop # ends loop & resumes program flow
        end

        def execute(method, &callback)
          @callback = callback
          send_data(method)
        end

      end

    end

And finally the example usage:

    @@ruby

    require File.join(File.dirname(__FILE__), 'echo_server')
    require File.join(File.dirname(__FILE__), 'echo_client')

    EchoServer.start

    10.times do |i|
      puts EchoClient.get(i)
    end

    EchoServer.stop

Personally, i prefer placing the server & client code inside a single file *echo_service.rb*,
since the client code is pretty coupled with the server code. One gotcha i've encountered
while working with this server/client thingy is that error in the server hangs the client,
that's why having the server log file is really useful in debugging.
