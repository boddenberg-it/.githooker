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
			rm -f "$hook"
		fi
	done
	#echo -e "\n${b}[INFO]${u} test setup cleaned for test of: ${b}$1${u}"
}

function success {
	echo -e "${g}${b}[SUCCESS]${d} ${u}$1"
}

function failure {
	echo -e "${r}${b}[FAILURE]${d} ${u}$1"
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
#hook_backup="$BASE/tests/hook_backup"
#mkdir -p "$hook_backup"
#cp "$BASE"/.git/hooks/* "$hook_backup"

# begin testing
echo -e "\n${b}######${u} starting .githooks tests suites ${b}######${u}"

# LIST
echo -e "\n${b}LIST TESTS$u"
ensure_clean_test_setup "list"
log="$BASE/tests/list.output"
create_hook pre-commit 0
create_hook pre-push 1
create_hook pre-rebase 2

list > log 2>&1

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

echo -e "\n${b}ENABLE TESTS$u"
ensure_clean_test_setup "enable one hook"
create_hook pre-commit 1

enable "pre-commit" > /dev/null 2>&1

if [ -f "$BASE/.git/hooks/pre-commit" ]; then
	success "enable one hook"
else
	failure "enable one hook"
fi

ensure_clean_test_setup "enable three hooks"
create_hook pre-commit 1
create_hook pre-push 1
create_hook pre-rebase 1

enable "pre-commit" "pre-push" "pre-rebase" > /dev/null 2&>1

if [ -f "$BASE/.git/hooks/pre-commit" ] && [ -f "$BASE/.git/hooks/pre-push" ] && [ -f "$BASE/.git/hooks/pre-rebase" ]; then
	success "enable three hooks"
else
	failure "enable three hooks"
fi

ensure_clean_test_setup "enable --all hooks"
create_hook pre-commit 1
create_hook pre-push 1
create_hook pre-rebase 1

enable --alls > /dev/null 2>&1

if [ -f "$BASE/.git/hooks/pre-commit" ] && [ -f "$BASE/.git/hooks/pre-push" ] && [ -f "$BASE/.git/hooks/pre-rebase" ]; then
	success "enable --all hooks"
else
	failure "enable --all hooks"
fi


# DISABLE
echo -e "\n${b}DISABLE TESTS$u"
ensure_clean_test_setup "disable one hook"
create_hook pre-commit 2

disable "pre-commit" > /dev/null 2&>1

if [ -f "$BASE/.git/hooks/pre-commit" ]; then
	failure "disable one hook"
else
	success "disable one hook"
fi

ensure_clean_test_setup "disable three hooks"
create_hook pre-commit 2
create_hook pre-push 2
create_hook pre-rebase 2

disable "pre-commit" "pre-push" "pre-rebase" > /dev/null 2&>1

if [ -f "$BASE/.git/hooks/pre-commit" ] || [ -f "$BASE/.git/hooks/pre-push" ] || [ -f "$BASE/.git/hooks/pre-rebase" ]; then
	failure "disable three hooks"
else
	success "disable three hooks"
fi

ensure_clean_test_setup "disable --all hooks"
create_hook pre-commit 2
create_hook pre-push 2
create_hook pre-rebase 2

disable --alls > /dev/null 2&>1

if [ -f "$BASE/.git/hooks/pre-commit" ] || [ -f "$BASE/.git/hooks/pre-push" ] || [ -f "$BASE/.git/hooks/pre-rebase" ]; then
	failure "disable --all hooks"
else
	success "disable --all hooks"
fi

# only when expect is installed on system
expect -v > /dev/null 2&>1
if [ $? = "0" ]; then
	
	echo -e "\n${b}INTERACTIVE TESTS$u"
	ensure_clean_test_setup "interactive"
	create_hook pre-commit 0
	create_hook pre-push 2
	create_hook pre-rebase 1

	# invoke expect
	start="$(date +%s)"
	expect $BASE/test_interactive.exp "n" > /dev/null 2&>1
	end="$(date +%s)"
	
	if [ $((end-start)) -lt 5 ]; then
		success "interactive test - answer no to all (smoke test)"
	else
		failure "interactive test - answer no to all (smoke test)"
	fi

	# invoke expect
	start="$(date +%s)"
	expect $BASE/test_interactive.exp "y" > /dev/null 2&>1
	end="$(date +%s)"
	
	if [ $((end-start)) = 5 ]; then
		failure "interactive test - answer yes to all"
	else
		# check if orphaned pre-commit is deleted
		if [ -f "$BASE/.git/hooks/pre-commit" ]; then
			failure "interactive test - delete orphaned hook"
		else
			success "interactive test - delete orphaned hook"
		fi
		# check it pre-push is disabled
		if [ -f "$BASE/.git/hooks/pre-push" ]; then
			failure "interactive test - disable enabled hook"
		else
			success "interactive test - disable enabled hook"
		fi
		# check if pre-rebase is enabled 
		if [ ! -f $BASE/.git/hooks/pre-rebases ]; then
			failure "interactive test - enable disabled hook"
		else
			success "interactive test - enable disabled hook"
		fi
	fi
else
	echo "\n$b[INFO]$u No expect installation found skipping interactive tests..."
fi
# restoring old hooks and deleting backup
ensure_clean_test_setup
#cp "$hook_backup"/* "$BASE"/.git/hooks/
#rm -rf "$hook_backup"
echo
