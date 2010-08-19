--- 
title: Benchmarking any Rake Task
date: 2010-08-13
category: ruby
tags: tips
---
While writing [serializable_proc](http://github.com/ngty/serializable_proc), i wanted
to find out how the RubyParser-based implementation fair against ParseTree-based one,
here's a rake task i've written to support the following use cases:

    # Case 1: Running with default set of rounds
    $ rake benchmark[spec]

And:

    # Case 2: Running with defined set of rounds
    $ rake benchmark[spec,2]

Here's the code to acheive the above:

    @@ruby

    # Benchmarking
    task :benchmark, :task, :times do |t, args|
      times, task = (args.times || 5).to_i.method(:times), args.task
      title = " ~ Benchmark Results for Task :#{task} ~ "
      results = [%w{nth}, %w{user}, %w{system}, %w{total}, %w{real}]

      # Running benchmarking & collecting results
      require 'benchmark'
      times.call do |i|
        result = Benchmark.measure{ Rake::Task[task].execute }.to_s
        regexp = /^\s*(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+\(\s*(\d+\.\d+)\)$/
        user, system, total, real = result.match(regexp)[1..-1]
        ["##{i.succ}", user, system, total, real].each_with_index do |val, j|
          results[j] << val
        end
      end

      # Formatting benchmarking results
      formatted_results = results.map do |rs|
        width = rs.map(&:to_s).map(&:size).max
        rs.map{|r| '  ' + r.ljust(width, ' ') }
      end.transpose.map{|row| row.join }

      # Showdown .. printout
      line = '=' * ([title.size, formatted_results.map(&:size).max].max + 2)
      puts [line, title, formatted_results.join("\n"), line].join("\n\n")

    end

Here's the output i get for the x2 run:

    ...
    (blah blah, the output of running :spec task x2)
    ...
    ===============================================

      ~ Benchmark Results for Task :spec ~

      nth  user       system   total     real
      #1   0.000000  0.000000  1.030000  1.052567
      #2   0.000000  0.000000  1.020000  1.040352

    ===============================================
