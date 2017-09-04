#!/bin/bash

function gduck {
	surf 'https://duckduckgo.com/html?q='$(echo "$@" | urlencode)
}
