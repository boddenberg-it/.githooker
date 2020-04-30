# create githook script with actual content
cat << EOF > "$BASE/githooks/pre-commit.sh"
#!/bin/bash
source "./generic_hooks.sh"

run_command_for_each_file "*.check" "touch"

run_command_for_each_file "*.foo,*.one" "touch"

run_command_once "*.check" "touch test_only_once_single_regex"

run_command_once "*.nope,*.check" "touch test_only_once_multiple_regex"

EOF
chmod 755 "$BASE/githooks/pre-commit.sh"

enable pre-commit > /dev/null

# trigger hook by creating commit
touch foo.check foobar.one
git add foo.check foobar.one
rm foo.check foobar.one test_only_once_single_regex test_only_once_multiple_regex 2> /dev/null
git commit -m "foo" > /dev/null

if [ -f "$BASE/foo.check" ] && [ -f "$BASE/foobar.one" ]; then
	success "run_command_for_each_file - one regex passed"
else
	failure "run_command_for_each_file - one regex passed"
fi

if [ -f "$BASE/foobar.one" ]; then
	success "run_command_for_each_file - multiple regex passed"
else
	failure "run_command_for_each_file - mutliple regex passed"
fi

if [ -f "$BASE/test_only_once_single_regex" ]; then
	success "run_command_once - one regex passed"
else
	failure "run_command_once - one regex passed"
fi

if [ -f "$BASE/test_only_once_multiple_regex" ]; then
	success "run_command_once - mutliple regex passed"
else
	failure "run_command_once - multiple regex passed"
fi
