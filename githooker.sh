#!/bin/bash

# without slashes
hook_dir=".githooks_for_testing" # TODO: rename to default ".githooks" and overwrite in run_tests!
 
BASE="$(git rev-parse --show-toplevel)"

# necessary to run .githooker tests in submodule dir,
# because .git/ is not a dir in a submodule.
GIT_HOOK_DIR=".git/hooks"

# colors for output messages
r="\x1B[31m" # red
y="\x1B[33m" # yellow
g="\x1B[32m" # green
d="\x1B[39m" # default
b="\x1B[1m"  # bold
u="\x1B[0m"  # unbold
cc="$d"      # current color

# both helper_{enable,disable} are the actual commands.
# but their names are sacrificed for .githooker/{enable,disable}
function actual_enable {
    hook="$1"

    # get hook extension if missing
    # if so, we get the hook_dir too
    if [[ $1 != *"."* ]]; then  
        hook="$(find "$hook_dir" -name "$1.*")"
    else
        # so we add it here
        hook="$hook_dir/$hook"
    fi
    ln -s -f ../../"$hook" "$GIT_HOOK_DIR/$2"
    # Note: "../.." is necessary because git hooks spawn in $GIT_HOOK_DIR
    echo -e "\t$b$1$u hook ${g}enabled${d}"
}

function actual_disable {
    hook="$1"
    # remove hook extension if there
    if [[ $1 = *"."* ]]; then
        hook="$(basename $1 | cut -d "." -f1)"
    fi
    echo "$BASE/$GIT_HOOK_DIR/$hook"
    unlink "$BASE/$GIT_HOOK_DIR/$hook" #> /dev/null

    if [ -n "$3" ]; then
        # orphaned hook links are deleted not disabled!
        echo -e "\t$b$1$u hook $3"
    else
        echo -e "\t$b$1$u hook ${y}disabled${d}"
    fi
}

function generic_toggle {
    if [ "$3" = "--all" ]; then
        for hook in $2; do
                # enable/disable pre-commit.sh pre.co
                $1 "$(basename $hook)" "$(cut -d '.' -f1 "$hook" 2> /dev/null)"
        done
    else
        command="$1"; shift; shift
        for hook in $@; do
            hook="$(basename $hook)"
            "$command" "$hook" "$(echo $hook | cut -d '.' -f1 2> /dev/null)"
        done
    fi
}

## actual commands/task which can be invoked
function disable {
    generic_toggle "actual_disable" "$BASE/$GIT_HOOK_DIR/*" $@
}

function enable {
    generic_toggle "actual_enable" "$BASE/$hook_dir/*" $@
}

# used by interactive
function awnser {
    read -r user_answer
    if [ "$user_answer" = "y" ] || [ "$user_answer" = "yes" ]; then
        echo "yes"
    fi
}

function interactive { # argumentless function
    echo -e "\n${b}[INFO]${u} each ${b}hook$u will be listed with its ${b}status$u. Say yes or no to change hook state. (y/${b}N$u)"

    for hook in "$BASE/$hook_dir/"*; do
        hook_without_extension="$(cut -d '.' -f1 "$hook")"

        if [ -f "$BASE/$GIT_HOOK_DIR/$hook_without_extension" ]; then
            echo -e "\n\t${g}${b}$hook_without_extension${u} hook is enabled${d}. Do you want to ${b}disable${u} it? (y/N)"

            if [ "$(awnser)" = "yes" ]; then
                actual_disable "$(basename $hook)"
            fi
        else
            echo -e "\n\t${y}${b}$hook_without_extension${u} hook is disabled${d}. Do you want to ${b}enable${u} it? (y/N)"

            if [ "$(awnser)" = "yes" ]; then
                actual_enable "$hook" "$hook_without_extension"
            fi
        fi
    done

    # searching for orphaned hooks in ./$GIT_HOOK_DIR
    for hook in "$BASE"/$GIT_HOOK_DIR/*; do

        # early return if file is sample file
        if [[ "$hook" == *".sample" ]]; then
            continue
        fi

        hook_script="$(find "$BASE/$hook_dir" -name "$(basename $hook).*")"

        if [ -z $hook_script ] || [ ! -f $hook_script ]; then
            echo -e "\n\t${r}$(basename $hook) hook is orphaned.$u Do you want to ${b}delete$u it? (y/N)${d}"

            if [ "$(awnser)" = "yes" ]; then
                actual_disable "$(basename $hook)" "foo" "${r}deleted${d}"
            fi
        fi
    done
    echo # new line at the end for better readability
}

function list { # argumentless function

    echo -e "\n${b}[INFO]${u} listing all hooks ${b}(${g}enabled${d}/${y}disabled${d}/${r}orphaned${d})${u}"

    for hook_absolute_path in "$BASE/$hook_dir/"*; do
        
        hook="$(basename $hook_absolute_path)"
        hook_without_extension="$(echo "$hook" | cut -d '.' -f1)"

        if [ -f "$BASE/$GIT_HOOK_DIR/$hook_without_extension" ]; then
            cc="$g"
        else
            cc="$y"
        fi
        echo -e "\t${b}${cc}$hook_without_extension${d}${u}"
    done

    # searching for orphaned-hooks/broken-links
    for file in "$BASE"/$GIT_HOOK_DIR/*; do

        if [[ $file == *".sample" ]]; then
            continue
        fi

        path_of_linked_script_by_hook="$(find "$BASE"/$hook_dir -name "$(basename $file).*")"

        if [ -z "$path_of_linked_script_by_hook" ] || [ ! -f "$path_of_linked_script_by_hook" ]; then
            echo -e "\t${r}$(basename $file)${d}"
        fi
    done
}

command=$1; shift
$command $@
