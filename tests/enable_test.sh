ensure_clean_test_setup "enable one hook"
disabled_hook pre-commit

enable "pre-commit" > /dev/null

if [ -L "$BASE/$GIT_HOOK_DIR/pre-commit" ]; then
	success "enable - one hook"
else
	failure "enable - one hook"
fi

ensure_clean_test_setup "enable three hooks"
disabled_hook pre-commit
disabled_hook pre-push
disabled_hook pre-rebase

enable "pre-commit" "pre-push" "pre-rebase" > /dev/null

if [ -L "$BASE/$GIT_HOOK_DIR/pre-commit" ] && [  -L "$BASE/$GIT_HOOK_DIR/pre-push" ] && [  -L "$BASE/$GIT_HOOK_DIR/pre-rebase" ]; then
	success "enable - three hooks"
else
	failure "enable - three hooks"
fi

ensure_clean_test_setup "enable --all hooks"
disabled_hook pre-commit
disabled_hook pre-push
disabled_hook pre-rebase

enable "--all" > /dev/null

if [ -L "$BASE/$GIT_HOOK_DIR/pre-commit" ] && [  -L "$BASE/$GIT_HOOK_DIR/pre-push" ] && [  -L "$BASE/$GIT_HOOK_DIR/pre-rebase" ]; then
	success "enable - all hooks (--all)"
else
	failure "enable - all hooks (--all)"
fi
