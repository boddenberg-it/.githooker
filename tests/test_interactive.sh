    # check if expect is available)
expect -v > /dev/null
if [ $? -gt 0 ]; then
	echo -e "${r}[WARNING]$u No expect installation found skipping interactive tests..."
else
	ensure_clean_test_setup "interactive"
	create_hook pre-commit 0
	create_hook pre-push 2
	create_hook pre-rebase 1
	
    start="$(date +%s)"
	expect "$BASE/tests/test_interactive.exp" "n" > /dev/null
	end="$(date +%s)"
	
    # evaluation (based on time out)
	if [ $((end-start)) -lt 15 ]; then
		success "interactive - smoke test (always no)"
	else
		failure "interactive - smoke test (always no)"
	fi
	
    start="$(date +%s)"
	expect "$BASE/tests/test_interactive.exp" "y" > /dev/null
	end="$(date +%s)"
	# check for timeout
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
