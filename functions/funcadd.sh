#!/bin/bash

funcdir=~/.scripts/bashconf/functions
function funcadd() {
	name="$1"
	file="${funcdir}/${name}.sh"
	cat > "${file}" <<EOF
function ${name}() {

}
EOF
	vim "${file}"
}
