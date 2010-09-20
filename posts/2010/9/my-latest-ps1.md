--- 
title: My Latest PS1
date: 2010-09-20
category: misc
tags: tips, bash
---
I really like my latest *PS1*, it shows my current:

* installed ruby (taking into account of the gemset, x3 cheers for RVM),
* working directory, and
* working git branch

Here's how it looks:

![PS1 Pic](/images/ps1.png "My PS1")

To achieve the above, here's a fragment of my *~/.bashrc*:

    @@shell

    # Retrieve the current git branch
    # See http://techdebug.com/blog/2009/11/28/git-branch-name-in-your-bash-prompt
    parse_git_branch() { git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/' ; }

    # Retrieve the current installed ruby
    installed_ruby() { gem env | grep 'INSTALLATION DIRECTORY' | sed 's/.*\/\(.*\)/(\1)/' ; }

    # Piecing everything together, the coloring takes abit of trial & error
    PS1="\033[01;32m\](\u@\h)\[\033[00m\]:\[\033[01;31m\]\$(installed_ruby)\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$(parse_git_branch)"

    # Root user shows '#' instead of '$'
    case `id -u` in
      0) PS1="${PS1}\n# ";;
      *) PS1="${PS1}\n$ ";;
    esac

