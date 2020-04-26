#!/bin/bash

BASE="$(git rev-parse --show-toplevel)"

# colors for output messages
r="\e[31m" # red
y="\e[33m" # yellow
g="\e[32m" # green
d="\e[39m" # default
cc="$d"    # current color    

# generic/helper functions
function generic_interactive {
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "yes" ]; then
        echo -e "\t... above hook is going to be $3."
        $1 "$2"
    else
        echo -e "\t... above hook is staying as is."
    fi
}

function generic_toggle {
    if [ $# -eq 2 ]; then
        if [ "$2" = "--all" ]; then
            for hook in githooks/*; do
                $1 "$hook" "$(cut -d '.' -f1 "$hook")"
            done
        else
            $1 "$2" "$(cut -d '.' -f1 "$2")"
        fi
    else
        command="$1"
        shift
        for hook in $@; do
                $command "$hook" "$(cut -d '.' -f1 "$hook")"
        done
    fi
}

function helper_enable {
    # ensure that passed gook holds actual extension:
    # a simple check whether a dot is in hook name should be sufficient,
    # because naming of all files within githooks/ must match list of git hooks.
    hook=""
    if [[ $1 == *"."* ]]; then
        hook="$1"
    else 
        hook_absolute_path="$(find "$BASE/test" -name "$1.*")"
        hook=${hook_absolute_path##*/}
    fi

    ln -s "$BASE/githooks/$hook" "$BASE/.git/hooks/$2"
    echo -e "\t$2 hook ${g}enabled${d}"
}

function helper_disable {
    rm "$BASE/.git/hooks/$2"
    echo -e "\t$2 hook ${y}disabled${d}"
}

## actual commands/task which can be invoked
function disable {
    generic_toggle "helper_disable" $@
}

function enable {
    generic_toggle "helper_enable" $@
}

function interactive { # argumentless function
    echo "[INFO] each hook will be listed with its status. Say yes or no to toggle its state (y/N)."

    # looping over hook in ./githooks/
    for hook in "$BASE"/githooks/*; do
        hook_without_extension="$(cut -d '.' -f1 "$hook")"

        if [ -f "$BASE/.git/hooks/$hook_without_extension" ]; then
            echo -e "\t$hook_without_extension hook is ${g}enabled${d}. Do you want to disable it? (y/N)"
            generic_interactive disable "$hook" "enabled"
        else
            echo -e "\t$hook_without_extension hook is ${y}disabled${d}. Do you want to enable it? (y/N)"
            generic_interactive enable "$hook" "disabled"
        fi 
    done

    # searching for orphaned hooks in ./.git/hooks
    for hook in "$BASE"/.git/hooks; do
        # early return if file is sample file
        if [[ "$hook" == *".sample"* ]]; then
            continue
        fi
        
        path_of_linked_script_by_hook="$(find "$BASE"/githooks/$hook.*)"
        
        if [ ! -f $path_of_linked_script_by_hook ]; then
            echo -e "\t${r}$hook hook is orphaned. Do you want to delete it? (y/N)${d}"
            generic_interactive disable "$hook" "deleted"
        fi
    done
}

function list { # argumentless function
    echo "[INFO] listing status of all available hooks in ./githooks/ (${g}enabled${d}/${y}disabled${d}/${r}orphaned${d})"

    # looping over hooks in ./githooks/
    for hook in "$BASE"/githooks/*; do
        hook_without_extension="$(cut -d '.' -f1 "$hook")"
    
        if [ -f "$BASE/.git/hooks/hook_without_extension" ]; then
            cc="$g"
        else
            cc="$y"
        fi
        echo -e "\t${cc}$hook_without_extension hook${d}"
    done

    # searching for orphaned hooks in ./.git/hooks
    for file in "$BASE"/.git/hooks; do
        # early return if file is sample file
        if [[ $1 == *".sample"* ]]; then
            continue
        fi
        
        path_of_linked_script_by_hook="$(find "$BASE"/githooks/$file.*)"

        if [ ! -f $path_of_linked_script_by_hook ]; then
            echo -e "\t${r}$file hook is orphaned!${d}"
        fi
    done
}

# short-hand aliases
alias l="list"
alias e="enable"
alias d="disable"
alias i="interactive"

# evaluating passed args 
command=$1; shift
$command $@
