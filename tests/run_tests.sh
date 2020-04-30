#!/bin/bash 
# Tips for debugging: simply search for it and remove "> /dev/null" from its 'actual command(s)'
# output from stderr may appear within successfully test cases.

function ensure_clean_test_setup {
	# clean up actual hooks
	rm -f "$BASE"/githooks/*

	# clean up all symbolic links
	for hook in "$BASE"/.git/hooks/*; do
		if [[ "$hook" != *".sample" ]]; then
			rm -f "$hook"
		fi
	done
}

function success {
	echo -e "${g}${b}[SUCCESS]${d} ${u}$1"
}

function failure {
	echo -e "${r}${b}[FAILURE]${d} ${u}$1"
	final_test_result="1"
}

function orphaned_hook {
	ln -s "$BASE/githooks/$1.ext" "$BASE/.git/hooks/$1"
}

function disabled_hook {
	echo "$1" > "$BASE/githooks/$1.ext"
}

function enabled_hook {
	echo "$1" > "$BASE/githooks/$1.ext"
	ln -s "$BASE/githooks/$1.ext" "$BASE/.git/hooks/$1"
}
function create_hook {
	# $1:
	#	- hook e.g. 'pre-commit', 'post-merge'
	# $2: 
	#	- 0 symbolic link in .git/hooks/ (orphaned)
	#	- 1 creates hook in githooks/ (disabled)
	#	- * creates both of the above (enabled)
	
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

BASE="$(git rev-parse --show-toplevel)"

# check whether tests are invoked in .githooker and not in repo which is using it as a subomdule!
if [ "$(basename "$BASE")" != "githooks" ]; then

	# two checks to allow calling .githooker from super project, if not do not prompt anything.
	cd "$BASE/.githooker" 2> /dev/null || true
	BASE="$(git rev-parse --show-toplevel)"

	if [ "$(basename "$BASE")" != ".githooker" ]; then
		echo -e "\n[WARNING] calling .githooker tests on a different repo ($(basename "$BASE"))... aborting!\n"
		exit 1
	fi
fi
# sourcing script under test
source "$BASE/githooker.sh"

final_test_result=0

# switch_to_branch to not break local development, need stashing too (TODO)
current_branch="$(git branch --format='%(refname:short)' | head -n1)"
git branch -D testing_branch > /dev/null 2>&1
git branch testing_branch > /dev/null
git checkout testing_branch > /dev/null

echo -e "\n${b}######${u} starting .githooker test suites ${b}######${u}\n"

echo -e "\n${b}TESTS OF: .githooker/generic_hooks.sh$u"

source "$BASE/tests/test_generic_hooks.sh"

echo -e "\n${b}TESTS OF: .githooker/do$u"

source "$BASE/tests/test_list.sh"

source "$BASE/tests/test_enable.sh"

source "$BASE/tests/test_disable.sh"

source "$BASE/tests/test_interactive.sh"

# clean up
rm "$BASE/foo.check" "$BASE/bar.check" "$BASE/githooks/pre-commit" \
	test_only_once_single_regex test_only_once_multiple_regex > /dev/null 2>&1

ensure_clean_test_setup
echo
git checkout "$current_branch" > /dev/null
git branch -D testing_branch > /dev/null 2>&1
echo
exit $final_test_result
