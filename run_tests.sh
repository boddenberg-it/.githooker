#!/bin/bash 
BASE="$(git rev-parse --show-toplevel)"

# check whether tests are invoked in .githooker and not in repo which is using it as a subomdule!
if [ "$(basename "$BASE")" != "githooks" ]; then
	# two checks to allow calling .githooker from super project
	cd "$BASE/.githooker"
	BASE="$(git rev-parse --show-toplevel)"
	
	if [ "$(basename "$BASE")" != ".githooker" ]; then
		echo -e "\n[WARNING] calling .githooker tests on a different repo ($(basename "$BASE"))... aborting!\n"
		exit 1
	fi
fi

# sourcing script under test
source "$BASE/do"

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

# create backup of .git/hooks/*
hook_backup="$BASE/tests/hook_backup"
mkdir -p "$hook_backup"
cp "$BASE"/.git/hooks/* "$hook_backup"

# begin testing
echo -e "\n${b}######${u} starting .githooker test suites ${b}######${u}"
final_test_result=0

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
enable "pre-commit" > /dev/null 2>&1
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
enable "pre-commit" "pre-push" "pre-rebase" > /dev/null 2>&1
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
enable "--all" > /dev/null 2>&1
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
disable "pre-commit" > /dev/null 2>&1
# evaluation
if [ -f "$BASE/.git/hooks/pre-commit" ]; then
	failure "disable - one hook"
else
	success "disable -  one hook"
fi

ensure_clean_test_setup "disable one hook"
# setup
create_hook pre-commit 0
# command under test
disable "pre-commit" > /dev/null 2>&1
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
disable "--all" > /dev/null 2>&1
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
	if [ $((end-start)) -lt 5 ]; then
		success "interactive - smoke test (always no)"
	else
		failure "interactive - smoke test (always no)"
	fi
	# command under test
	start="$(date +%s)"
	expect "$BASE/test_interactive.exp" "y" > /dev/null 2>&1
	end="$(date +%s)"
	# evaluations:
	if [ $((end-start)) = 5 ]; then
		"${r}${b}[TIMEOUT]${d} ${u}interactive - answer yes to all"
	fi
	# check if orphaned pre-commit is deleted
	if [ -f "$BASE/.git/hooks/pre-commit" ]; then
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
	if [ -f "$BASE/.git/hooks/pre-rebases" ]; then
		success "interactive - enable disabled hook"
	else
		failure "interactive - enable disabled hook"
	fi
fi

exit 0
echo -e "\n${b}TESTS OF: .githooker/generic_hooks.sh$u"
# setup
current_branch="$(git branch --show-current)"
git branch -d testing_branch > /dev/null 2>&1 || true
git branch testing_branch > /dev/null 2>&1 || true
git checkout test > /dev/null 2>&1
touch "$BASE/foo.check" "$BASE/bar.check"
cat << EOF > "$BASE/githooks/pre-commit"
#!/bin/bash
source "$BASE.githooker/do"

run_command_for_each_file "*.check" "touch tests/\$changed_file\"

run_command_for_each_file "*.does_multiple_command_regex_work,*.check" "touch tests/\${changed_file}-multiple_regex"

run_command_once "*.check" "touch tests/run_command_once"

run_command_once "*.nope,*.check" "touch tests/run_command_once_multiple_regex; exit 1"

EOF
# actual commands
enable pre-commit > /dev/null 2>&1
git add foo.check bar.check foobar.one > /dev/null 2>&1
git commit -m "Test .githooker/do: if u read this: write male to githooker@boddenberg-it.de" > /dev/null 2>&1
# evaluations
if [ -f "$BASE/tests/foo.check" ] && [ -f "$BASE/tests/bar.check" ]; then
	success "run_command_for_each_file - one regex passed"
else
	failure "run_command_for_each_file - one regex passed"
fi
if [ -f "$BASE/tests/foo.check-multiple_regex" ] && [ -f "$BASE/tests/bar.check-multiple_regex" ]; then
	success "run_command_for_each_file - multiple regex passed"
else
	failure "run_command_for_each_file - mutliple regex passed"
fi
if [ -f "$BASE/tests/tests/run_command_once" ]; then
	success "run_command_once - one regex passed"
else
	failure "run_command_once - one regex passed"
fi
if [ -f "$BASE/tests/run_command_once_multiple_regex" ]; then
	success "run_command_once - mutliple regex passed"
else
	failure "run_command_once - multiple regex passed"
fi
# clean up
rm "$BASE/foo.check" "$BASE/bar.check" "$BASE/githooks/pre-commit"
git stash > /dev/null 2>&1 || true  
git checkout "$current_branch" > /dev/null 2>&1

# restoring old hooks and deleting backup
ensure_clean_test_setup
cp "$hook_backup"/* "$BASE/.git/hooks/"
rm -rf "$BASE"/tests/*
echo
exit $final_test_result
