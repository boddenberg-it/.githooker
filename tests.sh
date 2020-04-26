#!/bin/bash 
BASE="$(git rev-parse --show-toplevel)"

# check whether tests are invoked in .githooks and not in repo which is using it as a subomdule!
if [ "$(basename "$BASE")" != "githooks" ]; then
	echo -e "\n[WARNING] calling .githooks tests on a different repo ($(basename "$BASE"))... aborting!\n"
	exit 1
fi

# sourcing script under test
source helper.sh

function ensure_clean_test_setup {
	# clean up actual hooks
	rm -f "$BASE"/githooks/* 

	# clean up all symbolic links
    for hook in "$BASE"/.git/hooks/*; do
		if [[ "$hook" != *".sample" ]]; then
			echo "rm -f $hook"
			rm -f "$hook"
		fi
	done
	echo -e "\n${b}[INFO]${u} test setup cleaned for test of: ${b}$1${u}"
}

function create_hook {
	# $1:
	#	- hook e.g. 'pre-commit', 'post-merge'
	# $2: 
	#	- 0 symbolic link in .git/hooks/ (orphaned)
	#   - 1 creates hook in githooks/	 (disabled)
	#   - * creates both of the above	 (enabled)
	
	hook="$BASE/githooks/$1.ext"
	link="$BASE/.git/hooks/$1"
	
	echo "$1" > "$hook"
	ln -s "$hook" "$link"
	
	if [ "$2" = "0" ]; then
		rm "$hook"
	elif [ "$2" = "1" ]; then
		rm "$link"
	fi
}

# create backup of .git/hooks/*
hook_backup="$BASE/tests/hook_backup"
mkdir -p "$hook_backup"
cp "$BASE"/.git/hooks/* "$hook_backup"

# begin testing
echo -e "\n${b}######${u} starting .githooks tests suites ${b}######${u}"

ensure_clean_test_setup "enable"



#echo -e "${b}[INFO]${u}"

# restoring old hooks and deleting backup
cp "$hook_backup"/* "$BASE"/.git/hooks/
rm -rf "$hook_backup"
echo