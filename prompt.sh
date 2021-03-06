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
#NOTIFY_PGM=notify-send
NOTIFY_PGM=true

function bright {
	color="$1"
	echo $((color + 60))
}

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

if [ "$TERM" == linux -o "$TERM" = screen -o "$TERM" = screen-256color ]
then
	BOX_END="─ "
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
			prompt+="\[\033[0;${main_color}m\]┬┤ \[\033[1;$(bright $color)m\]${content}"
		else
			prompt+=" \[\033[0;${main_color}m\]│ \[\033[1;$(bright $color)m\]${content}"
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

# Specific to my (schubev) own (hackish) setup
function mail_part {
	mail_count=$(~/.scripts/newmail.sh)
	if [[ "$mail_count" -gt 0 ]]
	then
		echo "${mail_count}M"
	fi
}

function error_part {
	if [ $cmd_error != 0 ]
	then
		echo "#${cmd_error}"
	fi
}

function user_part {
	echo $(whoami)'\[\033['"$(bright $host_color)"'m\]@'$(hostname -s)
}

function git_part {
	branch=$(git symbolic-ref --short HEAD 2>/dev/null)
	changes=$(git status --porcelain 2>/dev/null | wc -l)
	if [ -n "$branch" ]
	then
		if [ "$changes" -gt 0 ]
		then
			echo "\[\033[$(bright $YELLOW)m*${branch}"
		else
			echo "*${branch}"
		fi
	fi
}

PROMPT_SHOW_DURATION_THRESHOLD=500
PROMPT_NOTY_DURATION_THRESHOLD=1000
PROMPT_WARN_DURATION_THRESHOLD=2000
function duration_part {
	if [[ "$LAST_CMD_DURATION" -ge "$PROMPT_SHOW_DURATION_THRESHOLD" ]]
	then
		echo ${LAST_CMD_DURATION}ms
	fi
}

function hs_part {
	hs --what=compact | tr -d ' '
}

function build_prompt {
	cmd_error=$LAST_CMD_STATUS
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
	prompt_part duration_part $main_color
	prompt_part hs_part $main_color

	# Closing separator
	prompt+=" \[\033[0;${main_color}m\]├${BOX_END}"

	# Bottom prompt
	prompt+="\n\[\033[0;${main_color}m\]└${BOX_END}\[\033[0m\]"
	export PS1="$prompt"
}

function millitime {
	echo $(( $(date '+%s%N') / 1000000 ))
}

function on_prompt {
	LAST_CMD_STATUS=$?
	on_command_end
	build_prompt
	LAST_PROMPT_TOKEN=$(( LAST_PROMPT_TOKEN + 1))
}

LAST_CMD_START=$(millitime)
function on_command_end {
	set_term_title "$PWD"
	if [[ "$LAST_PROMPT_TOKEN" == "$LAST_CMD_TOKEN" ]]
	then
		LAST_CMD_END=$(millitime)
		LAST_CMD_DURATION=$(( LAST_CMD_END - LAST_CMD_START ))
		if [[ "$LAST_CMD_DURATION" -ge 10000 ]]
		then
			if [[ "$LAST_CMD_STATUS" != 0 ]]
			then
				notify_urgency=critical
			else
				notify_urgency=normal
			fi
			$NOTIFY_PGM \
				-u $notify_urgency \
				-t 20000 \
				"Command terminated with status $LAST_CMD_STATUS" \
				"$LAST_CMD_RUN"
		fi
	fi
}

function set_term_title {
	local title="$1"
	case $TERM in
		st|st-*)
			echo -ne "\x1b]0;${title}\x07"
			;;
	esac
}

function on_command {
	LAST_CMD_RUN="$1"
	LAST_CMD_TOKEN="$LAST_PROMPT_TOKEN"
	LAST_CMD_START=$(millitime)
	set_term_title "${LAST_CMD_RUN}"
}

function on_debug {
	if [[ "$BASH_COMMAND" != "$PROMPT_COMMAND" ]]
	then
		LAST_CMD="$BASH_COMMAND"
		on_command "$BASH_COMMAND"
	fi
}

export PROMPT_COMMAND=on_prompt
export PS2="─${BOX_END}"
export PS3="?${BOX_END}"
export PS4="+${BOX_END}"

trap on_debug DEBUG

# TODO: Make color escapes easier to deal with
