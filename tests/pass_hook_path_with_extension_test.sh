ensure_clean_test_setup "passing path to hook script"
disabled_hook pre-commit
disabled_hook pre-push
touch "$hook_dir/pre-applypatch"

enable ".githook/pre-commit.sh" "pre-push.ext" "pre-applypatch" > /dev/null

if [ -L "$BASE/$GIT_HOOK_DIR/pre-commit" ]; then
	success "enable - passing path to hook script"
else
	failure "enable - passing path to hook script"
fi

if [  -L "$BASE/$GIT_HOOK_DIR/pre-push" ]; then
	success "enable - passing hook with extension"
else
	failure  "enable - passing hook with extension"
fi

if [  -L "$BASE/$GIT_HOOK_DIR/pre-applypatch" ]; then
	success "enable - passing hook without extension"
else
	failure  "enable - passing hook without extension"
fi


disable ".githook/pre-commit.sh" "pre-push.ext" "pre-applypatch" > /dev/null

if [ ! -L "$BASE/$GIT_HOOK_DIR/pre-commit" ]; then
	success "disable - passing path to hook script"
else
	failure "disable - passing path to hook script"
fi

if [ ! -L "$BASE/$GIT_HOOK_DIR/pre-push" ]; then
	success "disable - passing hook with extension"
else
	failure  "disable - passing hook with extension"
fi

if [ ! -L "$BASE/$GIT_HOOK_DIR/pre-applypatch" ]; then
	success "disable - passing hook without extension"
else
	failure  "disable - passing hook without extension"
fi

touch $BASE/$GIT_HOOK_DIR/pre-commit
disable "pre-commit" > /dev/null

if [ -f  "$BASE/$GIT_HOOK_DIR/pre-commit" ]; then
	success "disable - does not remove actual file in $GIT_HOOK_DIR/"
else
	failure  "disable  - does not remove actual file in $GIT_HOOK_DIR"
fi