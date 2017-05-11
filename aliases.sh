#!/bin/bash

alias reload='source ~/.bashrc'

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
