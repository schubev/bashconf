#!/bin/bash

export NOTEPAD_DIR=${NOTEPAD_DIR:=~/Documents/notes/.pad}

_notepad_last_name=
_notepad_last_count=

function _notepad_gen_name() {
	local name="note_$(date -u '+%Y-%m-%dT%H%M')"
	if [[ "$name" = "$_notepad_last_name" ]]
	then
		_notepad_last_count=$((_notepad_last_count + 1))
	else
		_notepad_last_name="$name"
		_notepad_last_count=0
	fi
	printf '%s_%02u' "$name" "$_notepad_last_count"
}

function notepad() {
	if [[ -z "$1" ]]
	then
		command=new
	else
		command="$1"
		shift
	fi
	case "$command" in
	new)
		mkdir -p "$NOTEPAD_DIR"
		$EDITOR "${NOTEPAD_DIR}/$(_notepad_gen_name)"
		;;
	list)
		if [[ -d "$NOTEPAD_DIR" ]]
		then
			ls "$NOTEPAD_DIR"
		fi
		;;
	last)
		if [[ -d "$NOTEPAD_DIR" ]]
		then
			local last="$(ls "$NOTEPAD_DIR" | tail -n 1)"
			if [[ -f "$last" ]]
			then
				$EDITOR "${NOTEPAD_DIR}/${last}"
			else
				1>&2 echo "There are no notes."
			fi

		else
			1>&2 echo "There are no notes."
		fi
		;;
	purge) # Remove empty notes.
		if [[ -d "$NOTEPAD_DIR" ]]
		then
			stat --format='%s %n' "$NOTEPAD_DIR"/* \
				| sed -rn -e '/^0 /{s/^0 //;p}' \
				| xargs --delimiter='\n' rm -I
		fi
	esac
}
