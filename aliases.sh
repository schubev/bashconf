#!/bin/bash

alias l='ls -l'
alias ll='ls -lA'
alias la='ls -la'

alias glip='echo $(curl -s ipecho.net/plain)'
alias rlock='sudo env VLOCK_MESSAGE="This machine is currently locked. Keep your fingers away you fat, nasty hobbitses!"\n"[Press any key to unlock]" USER=schube vlock -an'
alias ydl='youtube-dl -o "%(uploader)s.%(title)s.%(id)s.%(ext)s"'
alias reload='source ~/.bashrc'

for f in "${bashconf}/functions/"*
do
	source "$f"
done
