#!/bin/bash

BLACK=30
RED=31
GREEN=32
YELLOW=33
BLUE=34
PURPLE=35
CYAN=36
GREY=37

ERROR_COLOR=$RED
ROOT_COLOR=$YELLOW
SSH_COLOR=$CYAN
NORMAL_COLOR=$GREEN
CWD_ERROR=$PURPLE

if [ "$(id -u)" == "0" ]
then
	MAIN_COLOR=$YELLOW
else
	MAIN_COLOR=$GREEN
fi

if [ -n "$SSH_CLIENT" ]
then
	HOST_COLOR=$SSH_COLOR
else
	HOST_COLOR=$MAIN_COLOR
fi

if [ "$TERM" == linux ]
then
	BOX_END=" "
else
	BOX_END="╴"
fi

function build_prompt {
	cmd_error="$?"
	cwd_color=$CWD_ERROR
	if [ "$cmd_error" != 0 ]
	then
		main_color=$RED
		host_color=$RED
	else
		main_color=$MAIN_COLOR
		host_color=$HOST_COLOR
	fi

	prompt='\[\033[0m\]'
	# User and hostname
	prompt+="\[\033[${main_color}m\]┬┤\[\033[1m\] "
	prompt+="$(whoami)"
	prompt+="\[\033[${host_color}m\]@"
	prompt+="$(hostname)"

	# Time
	prompt+=" \[\033[0;${main_color}m\]│ \[\033[1;${main_color}m\]"
	prompt+="$(date '+%H:%M:%S')"

	# Current working directory
	prompt+=" \[\033[0;${main_color}m\]│ \[\033[1;${cwd_color}m\]"
	prompt+="$(pwd | sed "s/$(sed 's/\//\\\//g' <<< "$HOME" | tr -d '\n')/~/")"

	# Mails
	mail_count_file=/tmp/user-tmp-schube/mail_count
	if [ -r "$mail_count_file" ]
	then
		mail_count=$(cat $mail_count_file)
		if [ "$mail_count" != 0 ]
		then
			prompt+=" \[\033[0;${main_color}m\]│ \[\033[1m\]${mail_count}M"
		fi
	fi

	# Error status code
	if [ $cmd_error != 0 ]
	then
		prompt+=" \[\033[0;${main_color}m\]│ \[\033[1m\]#${cmd_error}"
	fi

	# Closing separator
	prompt+=" \[\033[0;${main_color}m\]├${BOX_END}"

	# Bottom prompt
	prompt+="\n\[\033[0;${main_color}m\]└${BOX_END}\[\033[0m\]"
	export PS1="$prompt"
}

export PROMPT_COMMAND=build_prompt
export PS2='─╴'
