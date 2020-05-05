#!/bin/bash 
# Tips for debugging: simply search for it and remove "> /dev/null" from its 'actual command(s)'
# output from stderr may appear within successfully test cases though.

# shared functions across all *_test scripts
function ensure_clean_test_setup {
	# clean up actual hooks
	rm -f "$BASE/$hook_dir/"*

	# clean up all symbolic links
	for hook in "$BASE/$GIT_HOOK_DIR"/*; do
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

# to easily create hooks for testing
function orphaned_hook {
	ln -s "$BASE/$hook_dir/$1.ext" "$BASE/$GIT_HOOK_DIR/$1"
}

function disabled_hook {
	echo "$1" > "$BASE/$hook_dir/$1.ext"
}

function enabled_hook {
	echo "$1" > "$BASE/$hook_dir/$1.ext"
	ln -s "$BASE/$hook_dir/$1.ext" "$BASE/$GIT_HOOK_DIR/$1"
}
###########################################################

# check whether we're called from .githooker or super project
BASE="$(git rev-parse --show-toplevel)"
TEST_BASE="$BASE"

if [[ "$BASE" != *".githooker" ]]; then
	TEST_BASE="$BASE/.githooker"
fi

# sourcing script under test for direct invokations
source "$TEST_BASE/githooker.sh"

# one may run tests before creating .githooks
mkdir -p "$hook_dir"

echo -e "#############################################"
echo -e "######${b} starting .githooker test suites ${u}######\n"

# switch_to_branch to not break local development
current_branch="$(git rev-parse --abbrev-ref HEAD)"
git branch -D githooker_testing_branch > /dev/null 2>&1
git branch githooker_testing_branch > /dev/null
git checkout githooker_testing_branch > /dev/null

source "$TEST_BASE/tests/generic_hooks_test.sh"

echo -e "\n${b}TESTSUITE .githooker/* commands$u"

source "$TEST_BASE/tests/list_test.sh"

source "$TEST_BASE/tests/enable_test.sh"

source "$TEST_BASE/tests/disable_test.sh"

source "$TEST_BASE/tests/pass_hook_path_with_extension_test.sh"

source "$TEST_BASE/tests/interactive_test.sh"

# clean up
rm "$BASE/foo.check" "$BASE/bar.check" "$BASE/$hook_dir/pre-commit" \
	test_only_once_single_regex test_only_once_multiple_regex > /dev/null 2>&1

ensure_clean_test_setup
echo
git checkout "$current_branch" > /dev/null
git branch -D githooker_testing_branch > /dev/null 2>&1
echo
exit $final_test_result
