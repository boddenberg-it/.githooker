#!/bin/bash
# This generic hook script shall be sourced by scripts in ./githooks/

function generic_hook {
	for changed_file in $(git diff HEAD  --name-only); do
		grep -- "$1" "$changed_file" > /dev/null
		if [ $? -eq 0 ]; then
        		$2
		fi
	done
}

function run_command_for_each_file {
	echo "${1//\,/\\|}" "$2 \$changed_file"
}

function run_command_once {
	generic_hook "${1//\,/\\|}" "$2; break"
}
