#!/bin/bash

BASE="$(git rev-parse --show-toplevel)"

# colors for output messages
g="\e[32m" # greens
y="\e[33m" # yellow
d="\e[39m" # default
cc="$d"    # current colors       

# generic/helper functions
function generic_interactive {
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "yes" ]; then
        echo -e "\t... above is going to be toggled."
        $1 "$2"
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
    ln -s "$BASE/githooks/$1" "$BASE/.git/hooks/$2"
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

function interactive {
    echo "[INFO] each hook will be listed with its status. Say yes or no to toggle its state (y/N)."

    for hook in "$BASE"/githooks/*; do
        hook_without_extension="$(cut -d '.' -f1 "$hook")"

        if [ -f "$BASE/.git/hooks/$hook_without_extension" ]; then
            echo -e "\t$hook_without_extension hook is ${g}enabled${d}. Do you want to disable it? (y/N)"
            generic_interactive disable "$hook"
        else
            echo -e "\t$hook_without_extension hook is ${y}disabled${d}. Do you want to enable it (y/N)"
            generic_interactive enable "$hook"
        fi 
    done
}

function list {
    echo "[INFO] listing status of all available hooks (${g}enabled${d}/${y}disabled${d})"

    for hook in "$BASE"/githooks/*; do
        hook_without_extension="$(cut -d '.' -f1 "$hook")"
    
        if [ -f "$BASE/.git/hooks/hook_without_extension" ]; then
            cc="$g"
        else
            cc="$y"
        fi
        echo -e "\t${cc}$hook_without_extension hook${d}"
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
