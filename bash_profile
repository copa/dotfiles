source ~/.git-prompt.sh
source ~/.aliases.sh

#if [ -f "/usr/local/opt/bash-git-prompt/share/gitprompt.sh" ]; then
#   __GIT_PROMPT_DIR="/usr/local/opt/bash-git-prompt/share"
#   source "/usr/local/opt/bash-git-prompt/share/gitprompt.sh"
#fi
 
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH:/usr/X11R6/bin

# Neuladen mit: source .bash_profile
#
#{\rtf1\ansi\ansicpg1252\cocoartf1138\cocoasubrtf320
#{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
#{\colortbl;\red255\green255\blue255;}

# shows all users of a group
# type: $ members wheel
members () { dscl . -list /Users | while read user; do printf "$user "; dsmemberutil checkmembership -U "$user" -G "$*"; done | grep "is a member" | cut -d " " -f 1; }; 

#\paperw11900\paperh16840\margl1440\margr1440\vieww10800\viewh8400\viewkind0
#\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural

# Wenn die MX Master sich immer verbindet/nicht verbindet, dann diese Datei löschen.
# sudo rm /Library//Preferences/com.apple.Bluetooth.plist

if tput setaf 1 &> /dev/null; then
    tput sgr0
    if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
#	echo "Color Definition 1"
      MAGENTA=$(tput setaf 9)
      ORANGE=$(tput setaf 172)
      GREEN=$(tput setaf 190)
      PURPLE=$(tput setaf 141)
      WHITE=$(tput setaf 0)
    else
	echo "Color Definition 2"
		BLACK=$(tput setaf 0)
		RED=$(tput setaf 1)
		GREEN=$(tput setaf 2)
		YELLOW=$(tput setaf 3)
		LIME_YELLOW=$(tput setaf 190)
		POWDER_BLUE=$(tput setaf 153)
		BLUE=$(tput setaf 4)
		MAGENTA=$(tput setaf 5)
		CYAN=$(tput setaf 6)
		WHITE=$(tput setaf 7)
		BRIGHT=$(tput bold)
		NORMAL=$(tput sgr0)
		BLINK=$(tput blink)
		REVERSE=$(tput smso)
		UNDERLINE=$(tput smul)
    fi
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
else
	echo "Color Definition 3"
    MAGENTA="\033[1;31m"
    ORANGE="\033[1;33m"
    GREEN="\033[1;32m"
    PURPLE="\033[1;35m"
    WHITE="\033[1;37m"
    BOLD=""
    RESET="\033[m"
fi

if [ -f `brew --prefix`/etc/bash_completion ]; then
	echo "Load GIT autocompletion"
    . `brew --prefix`/etc/bash_completion
else 
	echo "GIT autocompletion not found."
fi

function defread { defaults read $(echo "$@" | sed "s|\./|`pwd`/|g" | sed "s|.plist||g"); }

function isnt_connected () {
    scutil --nc status "VPN Felix" | sed -n 1p | grep -qv Connected
}

function poll_until_connected () {
    let loops=0 || true
    let max_loops=200 # 200 * 0.1 is 20 seconds. Bash doesn't support floats

    while isnt_connected "VPN Felix"; do
        sleep 0.1 # can't use a variable here, bash doesn't have floats
        let loops=$loops+1
        [ $loops -gt $max_loops ] && break
    done

    [ $loops -le $max_loops ]
}

# findText <file pattern> <search text>
# findText *.json spinner
function findInFiles() {
	find $1 -iname $2
}

function update_gem_outdated() {
	sudo gem update `sudo gem outdated | cut -d ' ' -f 1` --force
}

function launchXcode() {
	xv=`xcode-select -p`
	xn=`echo $xv | cut -d '/' -f 3`
	echo "Use $xn $1"
	open -a /Applications/$xn $1
}

function findfiles() {
	export LC_CTYPE=en_US.UTF-8
	find $1 -iname $2 -type f
}

function gitrebase() {
	git rebase -i HEAD~$1;
}

#e.g.: >gdrt "1.2.1.3"
#e.g.: >gdrt "pattern"
function gitDeleteRemoteTags() {
	git ls-remote --tags origin  | grep -E "$1" | sed 's/.*refs\/tags\//:/' |  xargs -n 1 git push origin;
}

# Mecurial
hg_dirty() {
    hg status --no-color 2> /dev/null \
    | awk '$1 == "?" { print "?" } $1 != "?" { print "" }' \
    | sort | uniq | head -c1
}

hg_in_repo() {
    [[ `hg branch 2> /dev/null` ]] && echo 'on '
}

hg_branch() {
    hg branch 2> /dev/null
}

fullBrewUpdate(){
            brew update

            casks=( $(brew cask list) )

            for cask in ${casks[@]}
            do
                # in the first line there is version
                    current="$(brew cask info $cask | sed -n '1p' | sed -n 's/^.*: \(.*\)$/\1/p')"

                    installed=( $(ls /opt/homebrew-cask/Caskroom/$cask))
                    if (! [[ " ${installed[@]} " == *" $current "* ]]); then
                            (set -x; brew cask install $cask --force;)
                    fi
            done

            brew upgrade
            brew cleanup
    }
	

export EDITOR="/usr/local/bin/mate -w"
export DIFF=/Applications/Kaleidoscope.app/Contents/MacOS/ksdiff

SUDO_PS1="\[\e[33;1;41m\][\u] \w \$\[\e[0m\] "
PS1='\[\033[m\]\n|\t| \u@\h:<\[${MAGENTA}\]\w\[${RESET}\>\[${ORANGE}\]`__git_ps1 "(%s)"`$(hg_branch)$(hg_dirty)\[${RESET}\]: '

# enable git unstaged indicators - set to a non-empty value
GIT_PS1_SHOWDIRTYSTATE="."
 
# enable showing of untracked files - set to a non-empty value
GIT_PS1_SHOWUNTRACKEDFILES="."
 
# enable stash checking - set to a non-empty value
GIT_PS1_SHOWSTASHSTATE="."
 
# enable showing of HEAD vs its upstream
GIT_PS1_SHOWUPSTREAM="auto"

# X11
#export DISPLAY=:0.0\

#eval "$(rbenv init -)"