#!/bin/bash

function duck {
	lynx -nopause -cookies 'https://duckduckgo.com/lite?q='$(echo "$@" | urlencode)
}
