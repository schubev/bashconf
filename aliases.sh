#!/bin/bash

alias l='ls -l'
alias ll='ls -lA'
alias la='ls -la'

alias glip='echo $(curl -s ipecho.net/plain)'
alias rlock='sudo env VLOCK_MESSAGE="This machine is currently locked. Keep your fingers away you fat, nasty hobbitses!"\n"[Press any key to unlock]" USER=schube vlock -an'
alias ydl='youtube-dl -o "%(uploader)s.%(title)s.%(id)s.%(ext)s"'
alias reload='source ~/.bashrc'
alias stirc='ssh -t celestia "tmux attach -t irc"'

function salias {
	definition="$1"
	alias "$1"
	echo "alias \"${definition}\"" >> ${bashconf}/local_aliases.sh
}

for alias_file in ${bashconf}/{global_aliases,local_aliases}.sh
do
	if [ -r "$alias_file" ]
	then
		source "$alias_file"
	fi
done

for f in "${bashconf}/functions/"*
do
	source "$f"
done
