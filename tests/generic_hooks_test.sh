# create githook script with actual content
cat << EOF > "$BASE/$hook_dir/pre-commit.sh"
#!/bin/bash
source "./generic_hooks.sh" "pre-commit"

run_command_for_each_file ".check" "touch"

run_command_for_each_file ".foo,.one" "touch"

run_command_once ".check" "touch test_only_once_single_regex"

run_command_once ".nope,.check" "touch test_only_once_multiple_regex"

EOF
chmod 755 "$BASE/$hook_dir/pre-commit.sh"

enable pre-commit > /dev/null

# trigger hook by creating commit
touch foo.check foobar.one
git add foo.check foobar.one
rm foo.check foobar.one test_only_once_single_regex test_only_once_multiple_regex 2> /dev/null

# hook-notification test via expect
expect -v > /dev/null
if [ $? -gt 0 ]; then
	echo -e "${r}[WARNING]$u No expect installation found skipping hook-notification test..."
else

	expect "$BASE/tests/notification_test.exp" "y" > /dev/null 2&>1

	if [ $? = 0 ]; then
		success "hook notification has ben printed to the terminal"
	else
		failure "hook notification has ben printed to the terminal"
	fi
fi

# to another commit to not rely on hook notification test
echo "foobar one" > foobar.one
echo "check one" > foo.check
git add foo.check foobar.one
git commit -m "commit for unit tests" > /dev/null

# non expect-related tests
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
