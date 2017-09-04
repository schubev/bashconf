function mdlynx {
	markdown_py < "$1" | lynx -stdin
}
