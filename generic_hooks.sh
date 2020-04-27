#!/bin/bash

function run_command_for_each_file {
	for changed_file in $(git diff HEAD --name-only --cached); do
		if [ $(echo "$changed_file" | grep -c "${1//\,/\\}") -lt 1 ]; then
			$2 "$changed_file"
		fi
	done
}

function run_command_once {
	for changed_file in $(git diff HEAD --name-only --cached); do
		if [ $(echo "$changed_file" | grep -c "${1//\,/\\}") -lt 1 ]; then
			$2
			break
		fi
	done
}
