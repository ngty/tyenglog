--- 
title: Automating M1 FBB Login
date: 2010-10-28
category: misc
tags: tips
---
Out with singtel's adsl, in with m1's cable broadband ... even though my original
plan is to go for fibre broadband, unfortunately opennet told me my home's fibre
termination point won't be ready until 6mths later, i have no choice but to
temporarily settle for a 6mths contract with m1's cable broadband service.

So far, i have no complaint abt my m1's cable broadband, except for the fact that
i need to manually perform login on m1's login page per 24hr, in order to continue
to access the internet, which is kind of irritating for me.

Since i use *dhcpcd* to configure my network interface (eg. wlan0), here's my
little shell script */usr/lib/dhcpcd/dhcpcd-hooks/90-m1-fbb-login* to automate
the process:

    @@shell

    #!/bin/bash

    USERID=blah    # as provided by m1
    PASSWORD=blah  # as provided by m1
    IP_PREFIX=blah # eg. '192.168.11.', to determine if login should be done
    LOGIN_URL='https://broadband.mobileone.net.sg/login/?.intl=sg'

    [ -n "`ifconfig | grep \"inet addr:${IP_PREFIX}\"`" ] && \
      [ -n "`ping -c1 8.8.8.8 | grep '100% packet loss'`" ] && \
        curl -d "userid=${USERID}&password=${PASSWORD}&act=login" $LOGIN_URL

Life as a programmer is really nice !!
