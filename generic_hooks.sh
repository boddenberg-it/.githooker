#!/bin/bash

function generic_hook {
	for changed_file in $(git diff HEAD --name-only); do
		if grep -- "$1" "$changed_file" > /dev/null; then
			$2
		fi
	done
}

function run_command_for_each_file {
	generic_hook "${1//\,/\\|}" "$2 \$changed_file"
}

function run_command_once {
	generic_hook "${1//\,/\\|}" "$2; break"
}
