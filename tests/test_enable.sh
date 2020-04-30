
ensure_clean_test_setup "enable one hook"
create_hook pre-commit 1

enable "pre-commit" > /dev/null

if [ -f "$BASE/.git/hooks/pre-commit" ]; then
	success "enable - one hook"
else
	failure "enable - one hook"
fi

ensure_clean_test_setup "enable three hooks"
create_hook pre-commit 1
create_hook pre-push 1
create_hook pre-rebase 1

enable "pre-commit" "pre-push" "pre-rebase" > /dev/null

if [ -f "$BASE/.git/hooks/pre-commit" ] && [ -f "$BASE/.git/hooks/pre-push" ] && [ -f "$BASE/.git/hooks/pre-rebase" ]; then
	success "enable - three hooks"
else
	failure "enable - three hooks"
fi

ensure_clean_test_setup "enable --all hooks"
create_hook pre-commit 1
create_hook pre-push 1
create_hook pre-rebase 1

enable "--all" > /dev/null

if [ -f "$BASE/.git/hooks/pre-commit" ] && [ -f "$BASE/.git/hooks/pre-push" ] && [ -f "$BASE/.git/hooks/pre-rebase" ]; then
	success "enable - all hooks (--all)"
else
	failure "enable - all hooks (--all)"
fi
