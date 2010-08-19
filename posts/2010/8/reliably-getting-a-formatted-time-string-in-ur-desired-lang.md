--- 
title: Reliably Getting a Formatted Time String in Ur Desired Lang
date: 2010-08-06
category: ruby
tags: tips, locale
---
Today, i'm spent quite abit of time playing with the very simple *Time#strftime*:

    @@ruby

    puts Time.now.strftime("%B %d, %Y %H:%M")
    # >> August 06, 2010 17:17

What i want to acheive is to reliably get the chinese version:

    八月 06, 2010 17:24

I've tried playing with the environment variable *$LANG*:

    $ export LANG=zh_CN.utf8
    $ locale
    LANG=zh_CN.utf8
    LC_CTYPE="zh_CN.utf8"
    LC_NUMERIC="zh_CN.utf8"
    LC_TIME="zh_CN.utf8"
    LC_COLLATE="zh_CN.utf8"
    LC_MONETARY="zh_CN.utf8"
    LC_MESSAGES="zh_CN.utf8"
    LC_PAPER="zh_CN.utf8"
    LC_NAME="zh_CN.utf8"
    LC_ADDRESS="zh_CN.utf8"
    LC_TELEPHONE="zh_CN.utf8"
    LC_MEASUREMENT="zh_CN.utf8"
    LC_IDENTIFICATION="zh_CN.utf8"
    LC_ALL=

Seems good, but nope, *Time#strftime* still gives me the same english output. I've trying
recompiling a different ruby using rvm with the exported *$LANG* ... nope, doesn't work
either. It seems that not matter how *$LANG* is set (thus affecting *LC_TIME*), ruby just
doesn't care abt it. Yet, i swear that on [flyhzm](http://github.com/flyerhzm)'s machine,
he has been getting the chinese version, no matter how hard he has tried to get the
english version.

Battled, beaten & worn out, i've concluded that the most reliable way (and definitely what
most people do), is to use the i18n. Given i already have this */path/to/i18n.yml*:

    @@yaml

    en:
      date:
        month_names: [~, January, February, March, April, May, June, July, August, September, October, November, December]

      time:
        formats:
          default: "%B %d, %Y %H:%M"

    zh:
      date:
        month_names: [~, 一月, 二月, 三月, 四月, 五月, 六月, 七月, 八月, 九月, 十月, 十一月, 十二月]

      time:
        formats:
          default: "%B %d, %Y %H:%M"

The following works for mri 1.9.1:

    @@ruby

    require 'rubygems'
    require 'i18n'

    I18n.load_path << '/tmp/i18n.yml'
    p I18n.available_locales  # >> [:en, :zh]

    I18n.locale = :en
    p I18n.localize(Time.now) # >> "August 06, 2010 17:48"

    I18n.locale = :zh
    p I18n.localize(Time.now) # >> "八月 06, 2010 17:48"

Without modication, i got the following unfriendly output for the chinese port under
mri 1.8.7, jruby & ree-1.8.7:

    \345\205\253\346\234\210 06, 2010 20:27

After much googling, stumbled across
[this post](http://blog.grayproductions.net/articles/ruby_18_character_encoding_flaws)
abt *$KCODE*. Here's the final modified code for the 1.8.7 equivalents:

    @@ruby

    require 'rubygems'
    require 'i18n'

    $KCODE = 'UTF-8' # Hey, this matters !!

    I18n.locale = :en
    p I18n.localize(Time.now) # >> "August 06, 2010 17:48"

    I18n.locale = :zh
    p I18n.localize(Time.now) # >> "八月 06, 2010 17:48"

For people doing rails, here are some useful resources:
* [Official Rails I18n Guide](http://guides.rubyonrails.org/i18n.html)
* [Useful I18n Snippets for Rails](http://github.com/svenfuchs/rails-i18n)
