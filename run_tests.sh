#!/bin/bash 
BASE="$(git rev-parse --show-toplevel)"

# check whether tests are invoked in .githooker and not in repo which is using it as a subomdule!
if [ "$(basename "$BASE")" != ".githooker" ]; then
	# two checks to allow calling .githooker from super project
	cd "$BASE/.githooker"
	BASE="$(git rev-parse --show-toplevel)"
	
	if [ "$(basename "$BASE")" != "githooks" ]; then
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
echo -e "\n${b}######${u} starting .githooks test suites ${b}######${u}"
final_test_result=0

# LIST TESTS
echo -e "\n${b}LIST TESTS$u"
# setup
ensure_clean_test_setup "list"
log="$BASE/tests/list.output"
create_hook pre-commit 0
create_hook pre-push 1
create_hook pre-rebase 2
# command under test
list > log 2>&1
# evaluations
if grep -q "31mpre-commit" "$log"; then
	success "list test - finds$r oprhaned$d hook"
else
	failure "list test - finds$r oprhaned$d hook"
fi
if grep -q "33mpre-push" "$log"; then
   	success "list test - finds$y disabled$d hook"
else
	failure "list test - finds$y disabled$d hook"
fi
if grep -q "32mpre-rebase" "$log"; then
   	success "list test - finds$g enabled$d hook"
else
	failure "list test - finds$g enabled$d hook"
fi

# ENABLE TESTS
echo -e "\n${b}ENABLE TESTS$u"
ensure_clean_test_setup "enable one hook"
# setup
create_hook pre-commit 1
# command under test
enable "pre-commit" > /dev/null 2>&1
# evaluation
if [ -f "$BASE/.git/hooks/pre-commit" ]; then
	success "enable one hook"
else
	failure "enable one hook"
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
	success "enable three hooks"
else
	failure "enable three hooks"
fi

ensure_clean_test_setup "enable --all hooks"
#setup
create_hook pre-commit 1
create_hook pre-push 1
create_hook pre-rebase 1
# command under test
enable --alls > /dev/null 2>&1
# evaluation
if [ -f "$BASE/.git/hooks/pre-commit" ] && [ -f "$BASE/.git/hooks/pre-push" ] && [ -f "$BASE/.git/hooks/pre-rebase" ]; then
	success "enable --all hooks"
else
	failure "enable --all hooks"
fi

# DISABLE TESTS
echo -e "\n${b}DISABLE TESTS$u"
ensure_clean_test_setup "disable one hook"
# setup
create_hook pre-commit 2
# command under test
disable "pre-commit" > /dev/null 2>&1
# evaluation
if [ -f "$BASE/.git/hooks/pre-commit" ]; then
	failure "disable one hook"
else
	success "disable one hook"
fi

ensure_clean_test_setup "disable one hook"
# setup
create_hook pre-commit 0
# command under test
disable "pre-commit" > /dev/null 2>&1
# evaluation
# check it pre-push is disabled
if [ ! -f "$BASE/.git/hooks/pre-push" ]; then
	success "disable orphaned hook"
else
	failure "disable orhaned hook"
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
	failure "disable three hooks"
else
	success "disable three hooks"
fi

ensure_clean_test_setup "disable --all hooks"
# setup
create_hook pre-commit 2
create_hook pre-push 2
create_hook pre-rebase 2
# command under test
disable --alls > /dev/null 2>&1
# evaluation
if [ -f "$BASE/.git/hooks/pre-commit" ] || [ -f "$BASE/.git/hooks/pre-push" ] || [ -f "$BASE/.git/hooks/pre-rebase" ]; then
	failure "disable --all hooks"
else
	success "disable --all hooks"
fi

# INTERACTIVE TESTS (check if expect is available)
if [ expect -v > /dev/null 2>&1 ]; then
	echo -e "\n${b}[INFO]$u No expect installation found skipping interactive tests..."
else
	echo -e "\n${b}INTERACTIVE TESTS$u"
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
		success "interactive test - answer no to all (smoke test)"
	else
		failure "interactive test - answer no to all (smoke test)"
	fi
	# command under test
	start="$(date +%s)"
	expect "$BASE/test_interactive.exp" "y" > /dev/null 2>&1
	end="$(date +%s)"
	# evaluations:
	if [ $((end-start)) = 5 ]; then
		"${r}${b}[TIMEOUT]${d} ${u}interactive test - answer yes to all"
	fi
	# check if orphaned pre-commit is deleted
	if [ -f "$BASE/.git/hooks/pre-commit" ]; then
		failure "interactive test - delete orphaned hook"
	else
		success "interactive test - delete orphaned hook"
	fi
	# check it pre-push is disabled
	if [ ! -f "$BASE/.git/hooks/pre-push" ]; then
		success "interactive test - disable enabled hook"
	else
		failure "interactive test - disable enabled hook"
	fi
	# check if pre-rebase is enabled
	if [ -f "$BASE/.git/hooks/pre-rebases" ]; then
		success "interactive test - enable disabled hook"
	else
		failure "interactive test - enable disabled hook"
	fi
fi

# restoring old hooks and deleting backup
ensure_clean_test_setup
cp "$hook_backup"/* "$BASE"/.git/hooks/
rm -rf "$hook_backup"
echo
exit $final_test_result
