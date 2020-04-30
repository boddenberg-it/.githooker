ensure_clean_test_setup "list"

create_hook pre-commit 0
create_hook pre-push 1
create_hook pre-rebase 2

log="$BASE/tests/list.output"
list > "$log"

if grep -q "31mpre-commit" "$log"; then
	success "list - finds$r oprhaned$d hook"
else
	failure "list - finds$r oprhaned$d hook"
fi

if grep -q "33mpre-push" "$log"; then
   	success "list - finds$y disabled$d hook"
else
	failure "list - finds$y disabled$d hook"
fi

if grep -q "32mpre-rebase" "$log"; then
   	success "list - finds$g enabled$d hook"
else
	failure "list - finds$g enabled$d hook"
fi

rm "$log"