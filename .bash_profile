#!/bin/bash
# ~/.bash_profile
# ------------------------------------------------------------
# Standard setup for my preferred login shell (bash). This
# includes some helper functions, environment variables, aliases
# and other customizations. Best used on a mac with terminal
# style set to "Homebrew" and "Use bright colors for bold text"
# ------------------------------------------------------------

#======================
# User-Specifc Settings
#======================
# touch a file in your home directory and save any machine-specific
# settings, or settings you don't want to check into Git there

if [ -f "$HOME/.$USER" ]; then
    source "$HOME/.$USER"
fi

#======================
# Environment Variables
#======================

umask 022

# set my PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set my PATH so it includes user's private bin if it exists
# pip install uses this convention when the --user flag is specified
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Set MySQL Path and Environment Variables
if [ -d /usr/local/mysql/bin ]; then
    PATH=$PATH:/usr/local/mysql/bin
fi

export CLICOLOR=1
export LSCOLORS=Hxgxcxdxbxegedabagacad

export EDITOR=nano

# Set default blocksize for ls, df, du
export BLOCKSIZE=1k

#========
# Aliases
#========
alias showpath='echo $PATH | tr ":" "\n" | nl'

alias ll='ls -FGlAhp'                       # Preferred 'ls' implementation
alias less='less -FSRXc'                    # Preferred 'less' implementation
cd() { builtin cd "$@"; ll; }
mcd () { mkdir -p "$1" && cd "$1"; }

alias ll='ls -Alth'
alias lsd='ls -l | grep "^d"'
alias lst='ls -R | grep ":$" | sed -e '"'"'s/:$//'"'"' -e '"'"'s/[^-][^\/]*\//--/g'"'"' -e '"'"'s/^/   /'"'"' -e '"'"'s/-/|/'"'"
alias u='clear; cd ../; pwd; ls -lhGgo'
alias d='clear; cd -; ls -lhGgo'

alias ~="cd ~"
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias ......='cd ../../../../../'

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'

# Make destructive operations interactive, just to be safe
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias mkdir='mkdir -pv'

#================
# Custom Calendar
#================

alias cal='echo; cal | grep -E --color "`date +%e`|$"'

#=============
# Slick Prompt
#=============

mdate=`date "+%a %b %d, %Y %T"`

export PS1="\[\033[1;33m\]$mdate\n\[\033[1;37m\][\w] \$(ls -1 | wc -l | sed 's: ::g') files\n\[\033[1;32m\]\u@\h$ \[\033[0m\]"

#==========
# Functions
#==========

# Find text in any file (ft "mytext" *.txt):
function ft { find . -name "$2" -exec grep -il "$1" {} \;; }

command_exists () {
    if type "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

encrypt () {
  # This function will encode the given file using the des3 encryption
  # and will save the file in the CWD with a  ".enc" extension.
  if [ $# -ne 1 ]; then
    echo >&2 "Error: encrypt() requires at least one filename as input"
    return 1
  fi
  if [ ! -f $1 ]; then
    echo >&2 "Error: $1 is not a file"
    return 1
  fi
  if command_exists 'openssl'; then
    savefile=`basename $1`
    openssl des3 -salt -in $1 -out $savefile.enc
    rm -i $1
  else
    echo >&2 "Error: encrypt() requires openssl"
    return 1
  fi
}

decrypt () {
  # This function will truncate the extension (.enc) that is
  # added by the companion "encrypt" function.
  if [ $# -ne 1 ]; then
    echo >&2 "Error: decrypt() requires at least one filename as input"
    return 1
  fi
  if [ ! -f $1 ]; then
    echo >&2 "Error: $1 is not a file"
    return 1
  fi
  local length=${#1}
  local extension=${1:(-4)}
  if [ $extension != ".enc" ]; then
    echo >&2 "Error: file is not of type .enc"
    return 1
  fi
  if command_exists 'openssl'; then
    local filenm=$length-4
    local outfile=${1:0:$filenm}
    openssl des3 -d -in $1 -out $outfile
    rm -i $1
  else
    echo >&2 "Error: encrypt() requires openssl"
    return 1
  fi
}

# Color Codes (Light)    Color Codes (Bold) Background Colors
# Black       0;30     Dark Gray    1;30    Black       40
# Red         0;31     Bold Red     1;31  Red           41
# Green       0;32     Bold Green   1;32  Green     42
# Brown       0;33     Yellow       1;33  Yellow    43
# Blue        0;34     Bold Blue    1;34  Blue      44
# Purple      0;35     Bold Purple  1;35  Magenta   45
# Cyan        0;36     Bold Cyan    1;36  Cyan      46
# Gray            0;37     White        1;37  Gray      47
#
# Set Color Example: \033[1;37;44m
# Color Reset: \033[0m

bar () {
    local ticks=""
    local counter=0
    while [ $counter -lt $COLUMNS ]; do
     ticks=$ticks"-"
     let counter=counter+1
    done
    echo -e "\n\033[1;30;47m${ticks}\033[0m\n"
}

colors () {
    #   This function echoes a bunch of color codes to the
    #   terminal to demonstrate what's available.  Each
    #   line is the color code of one forground color,
    #   out of 17 (default + 16 escapes), followed by a
    #   test use of that color on all nine background
    #   colors (default + 8 escapes).

    T='gYw'   # The test text

    echo -e "\n\t 0m\t 40m\t 41m\t 42m\t 43m\t 44m\t 45m\t 46m\t 47m";

    for FGs in '   0m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' '  36m' '1;36m' '  37m' '1;37m';
      do FG=${FGs// /}
      echo -en " $FGs \033[$FG  $T  "
      for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
        do echo -en " \033[$FG\033[$BG  $T  \033[0m";
      done
      echo;
    done
    echo;
}

countunique () {
  # This function counts the unique occurrences of every value in
  # a given field within a tab delimited text file.
  # Example Usage: countunique test-file.tsv '$25'
  if [ $# -ne 2 ]; then
    echo >&2 "countunique() requires a filename as input and a field number to display"
    return 1
  fi
  local f="$2"
    cat "$1" | awk -F '\t' "{print $f}" | sort | uniq -c | sort -r
}

function GetEXIFDateTimeFilename () {
  local exifdate=`jhead -se "$1" | grep "Date/Time" | sed 's/Date\/Time//;s/://g;s/ //g'`
  if [ -z "$exifdate" ] || [ "$exifdate" = "00000000000000" ]
  then
    echo `basename "$1"`
  else
    echo "$exifdate.jpg"
  fi
}

gpg_key () {
# This function will show the gpg associated to an encrypted gpg file
  if [ $# -ne 1 ]; then
    echo "gpg_key() requires at least one filename as input"
    return 1
  fi
  if command_exists 'gpg'; then
   key=`gpg --batch --decrypt --list-only --status-fd 1 "$1" 2>/dev/null | awk '/^\[GNUPG:\] ENC_TO / { print $3 }'`
   echo $key
   gpg --list-keys $key
  else
    echo "gpg is not  installed!"
  fi
}

function extract {
 if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
    return 1
 else
    for n in $@
    do
      if [ -f "$n" ] ; then
          case "${n%,}" in
            *.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                         tar xvf "$n"       ;;
            *.lzma)      unlzma ./"$n"      ;;
            *.bz2)       bunzip2 ./"$n"     ;;
            *.rar)       unrar x -ad ./"$n" ;;
            *.gz)        gunzip ./"$n"      ;;
            *.zip)       unzip ./"$n"       ;;
            *.z)         uncompress ./"$n"  ;;
            *.7z|*.arj|*.cab|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.rpm|*.udf|*.wim|*.xar)
                         7z x ./"$n"        ;;
            *.xz)        unxz ./"$n"        ;;
            *.exe)       cabextract ./"$n"  ;;
            *)
                         echo "extract: '$n' - unknown archive method"
                         return 1
                         ;;
          esac
      else
          echo "'$n' - file does not exist"
          return 1
      fi
    done
fi
}
