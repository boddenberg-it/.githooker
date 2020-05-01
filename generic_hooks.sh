#!/bin/bash -e

b="\x1B[1m"  # bold
u="\x1B[0m"  # unbold

exit_code=0

function run_command_for_each_file {
	for changed_file in $(git diff HEAD --name-only --cached); do
		if [ $(echo "$changed_file" | grep -c -e "${1//\,/\\|}") = 1 ]; then
			$2 "$changed_file"
			exit_code=$((exit_code+$?))
		fi
	done
}

function run_command_once {
	for changed_file in $(git diff HEAD --name-only --cached); do
		if [ $(echo "$changed_file" | grep -c -e "${1//\,/\\|}") = 1 ]; then
			$2
			exit_code=$((exit_code+$?))
			continue
		fi
	done
}

echo -e "${b}[.githooker] $1 ${u}hook fired${b}!${u}"
