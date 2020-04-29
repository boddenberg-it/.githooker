#!/bin/bash 
BASE="$(git rev-parse --show-toplevel)"

# Tips for debugging: simply search for it and remove "> /dev/null" from its 'actual command(s)'

# check whether tests are invoked in .githooker and not in repo which is using it as a subomdule!
if [ "$(basename "$BASE")" != "githooks" ]; then
	# two checks to allow calling .githooker from super project, if not do not prompt anything.
	cd "$BASE/.githooker" 2> /dev/null
	BASE="$(git rev-parse --show-toplevel)"
	
	if [ "$(basename "$BASE")" != ".githooker" ]; then
		echo -e "\n[WARNING] calling .githooker tests on a different repo ($(basename "$BASE"))... aborting!\n"
		exit 1
	fi
fi

# sourcing script under test
source "$BASE/pimp.sh"

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

echo -e "\n${b}######${u} starting .githooker test suites ${b}######${u}\n"
final_test_result=0

# switch_to_branch to not break local development, need stashing too (TODO)
current_branch="$(git branch --format='%(refname:short)' | head -n1)"
git branch -D testing_branch > /dev/null 2>&1
git branch testing_branch > /dev/null
git checkout testing_branch > /dev/null

echo -e "\n${b}TESTS OF: .githooker/generic_hooks.sh$u"
# TODO put in test/
cat << EOF > "$BASE/githooks/pre-commit.sh"
#!/bin/bash
source "./generic_hooks.sh"

run_command_for_each_file "*.check" "touch"

run_command_for_each_file "*.foo,*.one" "touch"

run_command_once "*.check" "touch test_only_once_single_regex"

run_command_once "*.nope,*.check" "touch test_only_once_multiple_regex"

EOF
chmod 755 "$BASE/githooks/pre-commit.sh"

# actual commands
enable pre-commit > /dev/null

# trigger hook by creating commit

touch foo.check foobar.one
git add foo.check foobar.one #> /dev/null 2>&1
# clean
rm foo.check foobar.one test_only_once_single_regex test_only_once_multiple_regex 2> /dev/null
git commit -m "foo" > /dev/null

# evaluations
if [ -f "$BASE/foo.check" ] && [ -f "$BASE/foobar.one" ]; then
	success "run_command_for_each_file - one regex passed"
else
	failure "run_command_for_each_file - one regex passed"
fi
if [ -f "$BASE/foobar.one" ]; then
	success "run_command_for_each_file - multiple regex passed"
else
	failure "run_command_for_each_file - mutliple regex passed"
fi
if [ -f "$BASE/test_only_once_single_regex" ]; then
	success "run_command_once - one regex passed"
else
	failure "run_command_once - one regex passed"
fi
if [ -f "$BASE/test_only_once_multiple_regex" ]; then
	success "run_command_once - mutliple regex passed"
else
	failure "run_command_once - multiple regex passed"
fi

echo -e "\n${b}TESTS OF: .githooker/do$u"
# LIST TESTS
ensure_clean_test_setup "list"
# setup
log="$BASE/tests/list.output"
create_hook pre-commit 0
create_hook pre-push 1
create_hook pre-rebase 2
# command under test
list > "$log"
# evaluations
if grep -q "31mpre-commit" "$log"; then
	success "list - finds$r oprhaned$d hook"
else
	failure "list - finds$r oprhaned$d hook"
fi
if grep -q "33mpre-push" "$log"; then
   	success "list - finds$y disabled$d hook"
else
	failure "list - finds$y disabled$d hook"
fi
if grep -q "32mpre-rebase" "$log"; then
   	success "list - finds$g enabled$d hook"
else
	failure "list - finds$g enabled$d hook"
fi

# ENABLE TESTS
ensure_clean_test_setup "enable one hook"
# setup
create_hook pre-commit 1
# command under test
enable "pre-commit" > /dev/null
# evaluation
if [ -f "$BASE/.git/hooks/pre-commit" ]; then
	success "enable - one hook"
else
	failure "enable - one hook"
fi

ensure_clean_test_setup "enable three hooks"
# setup
create_hook pre-commit 1
create_hook pre-push 1
create_hook pre-rebase 1
# command under test
enable "pre-commit" "pre-push" "pre-rebase" > /dev/null
# evaluation
if [ -f "$BASE/.git/hooks/pre-commit" ] && [ -f "$BASE/.git/hooks/pre-push" ] && [ -f "$BASE/.git/hooks/pre-rebase" ]; then
	success "enable - three hooks"
else
	failure "enable - three hooks"
fi

ensure_clean_test_setup "enable --all hooks"
#setup
create_hook pre-commit 1
create_hook pre-push 1
create_hook pre-rebase 1
# command under test
enable "--all" > /dev/null
# evaluation
if [ -f "$BASE/.git/hooks/pre-commit" ] && [ -f "$BASE/.git/hooks/pre-push" ] && [ -f "$BASE/.git/hooks/pre-rebase" ]; then
	success "enable - all hooks (--all)"
else
	failure "enable - all hooks (--all)"
fi

# DISABLE TESTS
ensure_clean_test_setup "disable one hook"
# setup
create_hook pre-commit 2
# command under test
disable "pre-commit" > /dev/null
# evaluation
if [ -f "$BASE/.git/hooks/pre-commit" ]; then
	failure "disable - one hook"
else
	success "disable - one hook"
fi

ensure_clean_test_setup "disable one hook"
# setup
create_hook pre-commit 0
# command under test
disable "pre-commit" > /dev/null
# evaluation
# check it pre-push is disabled
if [ ! -f "$BASE/.git/hooks/pre-push" ]; then
	success "disable - orphaned hook"
else
	failure "disable - orhaned hook"
fi

ensure_clean_test_setup "disable three hooks"
# setup
create_hook pre-commit 2
create_hook pre-push 2
create_hook pre-rebase 2
# command under test
disable "pre-commit" "pre-push" "pre-rebase" > /dev/null 2>&1
# evaluation
if [ -f "$BASE/.git/hooks/pre-commit" ] || [ -f "$BASE/.git/hooks/pre-push" ] || [ -f "$BASE/.git/hooks/pre-rebase" ]; then
	failure "disable - three hooks"
else
	success "disable - three hooks"
fi

# TODO: test passing hook with extension, shouldn't break at all or even path! add those tests
ensure_clean_test_setup "disable --all hooks"
# setup
create_hook pre-commit 2
create_hook pre-push 2
create_hook pre-rebase 2
# command under test
disable --all > /dev/null 2>&1
# evaluation
if [ -f "$BASE/.git/hooks/pre-commit" ] || [ -f "$BASE/.git/hooks/pre-push" ] || [ -f "$BASE/.git/hooks/pre-rebase" ]; then
	failure "disable - all hooks (--all)"
else
	success "disable - all hooks (--all)"
fi

# INTERACTIVE TESTS (check if expect is available)
expect -v > /dev/null 2>&1
if [ $? -gt 0 ]; then
	echo -e "${r}[WARNING]$u No expect installation found skipping interactive tests..."
else
	# setup
	ensure_clean_test_setup "interactive"
	create_hook pre-commit 0
	create_hook pre-push 2
	create_hook pre-rebase 1
	# command under test
	start="$(date +%s)"
	expect "$BASE/test_interactive.exp" "n" > /dev/null 2>&1
	end="$(date +%s)"
	# evaluation (based on time out)
	if [ $((end-start)) -lt 15 ]; then
		success "interactive - smoke test (always no)"
	else
		failure "interactive - smoke test (always no)"
	fi
	# command under test
	start="$(date +%s)"
	expect "$BASE/test_interactive.exp" "y" > /dev/null 2>&1
	end="$(date +%s)"
	# evaluations:
	if [ $((end-start)) = 30 ]; then
		success "${r}${b}[TIMEOUT]${d} ${u}interactive - answer yes to all"
	fi
	# check if orphaned pre-commit is deleted
	if [ ! -f "$BASE/.git/hooks/pre-commit" ]; then
		success "interactive - delete orphaned hook"
	else
		failure "interactive - delete orphaned hook"
	fi
	# check it pre-push is disabled
	if [ ! -f "$BASE/.git/hooks/pre-push" ]; then
		success "interactive - disable enabled hook"
	else
		failure "interactive - disable enabled hook"
	fi
	# check if pre-rebase is enabled
	if [ -f "$BASE/.git/hooks/pre-rebase" ]; then
		success "interactive - enable disabled hook"
	else
		failure "interactive - enable disabled hook"
	fi
fi

# clean up
rm "$BASE/foo.check" "$BASE/bar.check" "$BASE/githooks/pre-commit" \
	test_only_once_single_regex test_only_once_multiple_regex > /dev/null 2>&1

ensure_clean_test_setup
echo
git checkout "$current_branch" > /dev/null
git branch -D testing_branch > /dev/null 2>&1
echo
exit $final_test_result
