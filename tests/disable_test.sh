
ensure_clean_test_setup "disable one hook"
enabled_hook pre-commit

disable "pre-commit" > /dev/null

if [ -f "$BASE/$GIT_HOOK_DIR/pre-commit" ]; then
	failure "disable - one hook"
else
	success "disable - one hook"
fi

ensure_clean_test_setup "disable one hook"
orphaned_hook pre-commit

disable "pre-commit" > /dev/null

if [ ! -f "$BASE/$GIT_HOOK_DIR/pre-push" ]; then
	success "disable - orphaned hook"
else
	failure "disable - orhaned hook"
fi

ensure_clean_test_setup "disable three hooks"
enabled_hook pre-commit
enabled_hook pre-push
enabled_hook pre-rebase

disable "pre-commit" "pre-push" "pre-rebase" > /dev/null 2>&1

if [ -f "$BASE/$GIT_HOOK_DIR/pre-commit" ] || [ -f "$BASE/$GIT_HOOK_DIR/pre-push" ] || [ -f "$BASE/$GIT_HOOK_DIR/pre-rebase" ]; then
	failure "disable - three hooks"
else
	success "disable - three hooks"
fi

ensure_clean_test_setup "disable --all hooks"
enabled_hook pre-commit
enabled_hook pre-push
enabled_hook pre-rebase

disable --all > /dev/null 2>&1

if [ -f "$BASE/$GIT_HOOK_DIR/pre-commit" ] || [ -f "$BASE/$GIT_HOOK_DIR/pre-push" ] || [ -f "$BASE/$GIT_HOOK_DIR/pre-rebase" ]; then
	failure "disable - all hooks (--all)"
else
	success "disable - all hooks (--all)"
fi
