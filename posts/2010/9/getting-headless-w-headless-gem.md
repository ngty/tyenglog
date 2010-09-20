--- 
title: Getting Headless w Headless Gem
date: 2010-09-20
category: ruby
tags: tips, ruby, cucumber
---
Out of the box, capybara runs firefox for selenium-webdriver. It may be fun
to see firefox popping up, and automating all user interaction with the browser.
I would say that it is a very impressive demonstration of automated testing
to non-technical people (eg. my ex-boss). BUT, it is really getting quite
irritating for me, most of the time.

The easiest way to run the browser headless is to use the *Xvfb* (fake X server)
script:

    $ xvfb-run ./script/cucumber

BUT if for some reason, u really really don't wanna type out the prepending
*xvfb-run*, u can try the [headless](http://github.com/leonid-shevtsov/headless)
gem, & add the following *features/support/headless.rb*:

    @@ruby

    Before do
      # Unless headless mode is explicitely turned off, we assume headless mode
      # when running in selenium mode.
      if ENV['HEADLESS'] != 'false' && Capybara.current_driver == :selenium
        # Use global to track & avoid registering Headless#destroy multiple times
        $has_started_headless ||= (
          require 'headless'
          headless = Headless.new
          headless.start
          at_exit{ headless.destroy }
          true
        )
      end
    end

Anyway, under the hood, *headless* is just like *xvfb-run*, acting as a wrapper
for *Xvfb*.
