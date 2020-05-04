echo -e "\n${b}TESTSUITE general hook tests$u"

##########################################
# create githook script with failing content
cat << EOF > "$BASE/$hook_dir/pre-commit.sh"
#!/bin/bash -e
source "$TEST_BASE/generic_hooks.sh" "pre-commit"

run_command_for_each_file ".test" "mkdir"

EOF
chmod 755 "$BASE/$hook_dir/pre-commit.sh"

enable pre-commit > /dev/null

# create commit which triggers failing hook
echo "foo" > foo.test
echo "foo" > bar.test
git add foo.test bar.test
git commit -m "let the fail begin" > /dev/null

# check if hook did block the commit
if [[ "$(git log -n1 | tail -n1)" != *"let the fail begin"* ]]; then
	success "does a failing hook block the commit?"
else
	failure "does a failing hook block the commit?"
fi

##########################################
# create githook script with actual content
cat << EOF > "$BASE/$hook_dir/pre-commit.sh"
#!/bin/bash
source "$TEST_BASE/generic_hooks.sh" "pre-commit"

run_command_for_each_file ".check" "touch"

run_command_for_each_file ".foo,.one" "touch"

run_command_once ".check" "touch test_only_once_single_regex"

run_command_once ".check" "$TEST_BASE/tests/_counter_for_run_once_test.sh"

run_command_once ".nope,.check" "touch test_only_once_multiple_regex"

EOF

# trigger hook by creating commit
touch foo.check foobar.one
git add foo.check foobar.one
rm foo.check foobar.one test_only_once_single_regex test_only_once_multiple_regex 2> /dev/null

# hook-notification test via expect
expect -v > /dev/null
if [ $? -gt 0 ]; then
	echo -e "${r}[WARNING]$u No expect installation found skipping hook-notification test..."
else

	expect "$TEST_BASE/tests/notification_test.exp" "y" > /dev/null

	if [ $? = 0 ]; then
		success "has hook notification been printed?"
	else
		failure "has hook notification been printed?"
	fi
fi

##########################################
echo -e "\n${b}TESTSUITE .githooker/generic_hooks.sh$u"

rm run_once 2> /dev/null # ensure run_once does not exist already

# to another commit to not rely on hook notification test
echo "foobar one" > foobar.one
echo "check one" > foo.check
touch bar.check
git add foo.check bar.check foobar.one
rm foo.check bar.check foobar.one
git commit -m "commit for unit tests" > /dev/null

# non expect-related tests
if [[ "$(wc -l < run_once)" = *"1"* ]]; then
	success "run_command_once - runs once"
else
	failure "run_command_once - runs once"
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

if [ -f "$BASE/foo.check" ] && [ -f "$BASE/bar.check" ]; then
	success "run_command_for_each_file - runs for each file"
else
	failure "run_command_for_each_file - runs for each file"
fi

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

# clean up
rm foo.check foobar.one test_only_once_single_regex test_only_once_multiple_regex run_once 2> /dev/null
