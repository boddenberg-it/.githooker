
ensure_clean_test_setup "disable one hook"
create_hook pre-commit 2

disable "pre-commit" > /dev/null

if [ -f "$BASE/.git/hooks/pre-commit" ]; then
	failure "disable - one hook"
else
	success "disable - one hook"
fi

ensure_clean_test_setup "disable one hook"
create_hook pre-commit 0

disable "pre-commit" > /dev/null

if [ ! -f "$BASE/.git/hooks/pre-push" ]; then
	success "disable - orphaned hook"
else
	failure "disable - orhaned hook"
fi

ensure_clean_test_setup "disable three hooks"
create_hook pre-commit 2
create_hook pre-push 2
create_hook pre-rebase 2

disable "pre-commit" "pre-push" "pre-rebase" > /dev/null 2>&1

if [ -f "$BASE/.git/hooks/pre-commit" ] || [ -f "$BASE/.git/hooks/pre-push" ] || [ -f "$BASE/.git/hooks/pre-rebase" ]; then
	failure "disable - three hooks"
else
	success "disable - three hooks"
fi

ensure_clean_test_setup "disable --all hooks"
create_hook pre-commit 2
create_hook pre-push 2
create_hook pre-rebase 2

disable --all > /dev/null 2>&1

if [ -f "$BASE/.git/hooks/pre-commit" ] || [ -f "$BASE/.git/hooks/pre-push" ] || [ -f "$BASE/.git/hooks/pre-rebase" ]; then
	failure "disable - all hooks (--all)"
else
	success "disable - all hooks (--all)"
fi
