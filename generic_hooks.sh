#!/bin/bash

b="\x1B[1m"  # bold
u="\x1B[0m"  # unbold

function run_command_for_each_file {
	for changed_file in $(ls); do
		if [ $(echo "$changed_file" | grep -c -e "${1//\,/\\}") = 1 ]; then
			$2 "$changed_file"
		fi
	done
}

function run_command_once {
	for changed_file in $(ls); do
		if [ $(echo "$changed_file" | grep -c -e "${1//\,/\\}") = 1 ]; then
			$2
			break
		fi
	done
}

echo -e "\n${b}[.githooker] $1 ${u}hook fired"

ln -s -f ../../.githooks/pre-commit.sh .git/hooks/pre-commit