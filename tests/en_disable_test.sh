ensure_clean_test_setup "enable --all hooks"
disabled_hook pre-commit
disabled_hook pre-push

enable ".githook/pre-commit.sh" "pre-push.sh" > /dev/null

if [ -L "$BASE/$GIT_HOOK_DIR/pre-commit" ]; then
	success "EN/DISable - passing path to hook script"
else
	failure "EN/DISable - passing path to hook script"
fi

if [  -L "$BASE/$GIT_HOOK_DIR/pre-push" ]; then
	success "EN/DISable - passing hook with extension"
else
	failure  "EN/DISable - passing hook with extension"
fi
