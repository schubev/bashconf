function he() {
	local prevumask=$(umask)
	umask 077
	local fifodir="$USER_TMP_PATH/termhere/"
	local target=$(pwd)
	mkdir -p "${fifodir}" 2>/dev/null
	for fifo in $(find "${fifodir}" -type p)
	do
		echo "${target}" > "$fifo"
	done
	umask "${prevumask}"
}

function wh() {
	local prevumask=$(umask)
	umask 077
	local fifodir="$USER_TMP_PATH/termhere/"
	mkdir -p "${fifodir}" 2>/dev/null
	local fifo="${fifodir}/${BASHPID}"
	mkfifo ${fifo}
	target=$(cat "${fifo}")
	cd ${target}
	rm "${fifo}"
	umask "${prevumask}"
}
