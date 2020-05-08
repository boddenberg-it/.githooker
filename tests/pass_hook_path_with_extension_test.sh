ensure_clean_test_setup "passing path to hook script"
disabled_hook pre-commit
disabled_hook pre-push
touch "$hook_dir/pre-applypatch"

enable ".githook/pre-commit.sh" "pre-push.ext" "pre-applypatch" > /dev/null

if [ -L "$BASE/$GIT_HOOK_DIR/pre-commit" ]; then
	success "Enable - passing path to hook script"
else
	failure "Enable - passing path to hook script"
fi

if [  -L "$BASE/$GIT_HOOK_DIR/pre-push" ]; then
	success "Enable - passing hook with extension"
else
	failure  "Enable - passing hook with extension"
fi

if [  -L "$BASE/$GIT_HOOK_DIR/pre-applypatch" ]; then
	success "Enable - passing hook without extension"
else
	failure  "Enable - passing hook without extension"
fi


disable ".githook/pre-commit.sh" "pre-push.ext" "pre-applypatch" > /dev/null

if [ ! -L "$BASE/$GIT_HOOK_DIR/pre-commit" ]; then
	success "Disable - passing path to hook script"
else
	failure "Disable - passing path to hook script"
fi

if [ ! -L "$BASE/$GIT_HOOK_DIR/pre-push" ]; then
	success "Disable - passing hook with extension"
else
	failure  "Disable - passing hook with extension"
fi

if [ ! -L "$BASE/$GIT_HOOK_DIR/pre-applypatch" ]; then
	success "Disable - passing hook without extension"
else
	failure  "Disable - passing hook without extension"
fi

touch $BASE/$GIT_HOOK_DIR/pre-commit
disable "pre-commit" > /dev/null

if [ -f  "$BASE/$GIT_HOOK_DIR/pre-commit" ]; then
	success "Disable - does not remove actual file in $GIT_HOOK_DIR/"
else
	failure  "Disable  - does not remove actual file in $GIT_HOOK_DIR"
fi