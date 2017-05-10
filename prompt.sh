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

function prompt_part {
	builder="$1"
	color="$2"

	content="$($builder $color)"
	if [ -n "$content" ]
	then
		if [ "$prompt_part_count" == 0 ]
		then
			prompt+="\[\033[0;${main_color}m\]┬┤ \[\033[1;${color}m\]${content}"
		else
			prompt+=" \[\033[0;${main_color}m\]│ \[\033[1;${color}m\]${content}"
		fi
		prompt_part_count=$((prompt_part_count + 1))
	fi
}

function cwd_part {
	pwd | sed "s/$(sed 's/\//\\\//g' <<< "$HOME" | tr -d '\n')/~/"
}

function date_part {
	date +%H:%M:%S
}

function mail_part {
	mail_count_file=/tmp/user-tmp-${USER}/mail_count
	if [ -r "$mail_count_file" ]
	then
		mail_count=$(cat $mail_count_file)
		if [ "$mail_count" != 0 ]
		then
			echo "${mail_count}M"
		fi
	fi
}

function error_part {
	if [ $cmd_error != 0 ]
	then
		echo "#${cmd_error}"
	fi
}

function user_part {
	echo $(whoami)'\[\033[${host_color}m\]@'$(hostname)
}

function git_part {
	branch=$(git symbolic-ref --short HEAD 2>/dev/null)
	changes=$(git status --porcelain | wc -l)
	if [ -n "$branch" ]
	then
		if [ "$changes" -gt 0 ]
		then
			echo "\[\033[${YELLOW}m*${branch}"
		else
			echo "*${branch}"
		fi
	fi
}

function build_prompt {
	cmd_error="$?"
	cwd_color=$CWD_ERROR
	prompt_part_count=0
	if [ "$cmd_error" != 0 ]
	then
		main_color=$RED
		host_color=$RED
	else
		main_color=$MAIN_COLOR
		host_color=$HOST_COLOR
	fi

	prompt='\[\033[0;37m\]¬'"$(printf "%$((COLUMNS - 1))s" '')"'\r'

	prompt_part user_part $main_color
	prompt_part date_part $main_color
	prompt_part cwd_part $PURPLE
	prompt_part mail_part $main_color
	prompt_part git_part $main_color
	prompt_part error_part $RED

	# Closing separator
	prompt+=" \[\033[0;${main_color}m\]├${BOX_END}"

	# Bottom prompt
	prompt+="\n\[\033[0;${main_color}m\]└${BOX_END}\[\033[0m\]"
	export PS1="$prompt"
}

export PROMPT_COMMAND=build_prompt
export PS2='─╴'
