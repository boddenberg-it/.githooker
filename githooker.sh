#!/bin/bash

# without slashes
hook_dir="githooks"

# colors for output messages
r="\x1B[31m" # red
y="\x1B[33m" # yellow
g="\x1B[32m" # green
d="\x1B[39m" # default
b="\x1B[1m" # bold
u="\x1B[0m" # unbold
cc="$d" # current color

BASE="$(git rev-parse --show-toplevel)"

# generic/helper functions

# doesn't work for disable, because we do not look for orphaned ones,
# seems like we can change it via parameter
function generic_toggle {
    if [ "$3" = "--all" ]; then
        for hook in $2; do
                $1 "$(basename $hook)" "$(cut -d '.' -f1 "$hook" 2> /dev/null)"
        done
    else
        command="$1"; shift; shift # TODO: remove this when we use generic_interactive as supposed isBoolean style
        for hook in $@; do
            hook="$(basename $hook)"
            "$command" "$hook" "$(echo $hook | cut -d '.' -f1 2> /dev/null)"
        done
    fi
}

function helper_enable {
    hook="$1"
    # ensure that passed gook holds actual extension:
    # a simple check whether a dot is in hook name should be sufficient,
    # because naming of all files within githooks/ must match list of git hooks.
    if [[ $1 != *"."* ]]; then  
        hook="$(find $BASE/$hook_dir -name $1.*)"
    fi
    # only because of --all
    if [[ $hook != *"/"* ]] ; then
        hook="$BASE/$hook_dir/$hook"
    fi

    # rename link into .git/hooks/-ish
    link="$BASE/.git/hooks/$2"
    # create symbolic link, if there just update it.
    ln "$hook" "$link"
    echo -e "\t$b$1$u hook ${g}enabled${d}"
}

function helper_disable {
    hook="$1"
    if [[ $1 = *"."* ]]; then
        hook="$(basename $1 | cut -d "." -f1)"
    fi
    
    rm "$BASE/.git/hooks/$hook" 2> /dev/null

    if [ ! -z $3 ]; then
        echo -e "\t$b$1$u hook $3"
    else
        echo -e "\t$b$1$u hook ${y}disabled${d}"
    fi
}

## actual commands/task which can be invoked
function disable {
    generic_toggle "helper_disable" "$BASE/.git/hooks/*" $@ 
}

function enable {
    generic_toggle "helper_enable" "$BASE/$hook_dir/*" $@
}

#
function generic_interactive {
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "yes" ]; then
        $1 "$2" "$3" "$4"
    fi
}

function interactive { # argumentless function
    echo -e "\n$b[INFO]$u each ${b}hook$u will be listed with its ${b}status$u. Say yes or no to change hook state. (y/${b}N$u)"

    # looping over hook in ./githooks/
    for hook in "$BASE/$hook_dir/"*; do
        hook_without_extension="$(cut -d '.' -f1 "$hook")"

        if [ -f "$BASE/.git/hooks/$hook_without_extension" ]; then
            echo -e "\n\t${g}${b}$hook_without_extension${u} hook is enabled${d}. Do you want to ${b}disable${u} it? (y/N)"
            generic_interactive helper_disable "$(basename $hook)"
        else
            echo -e "\n\t${y}${b}$hook_without_extension${u} hook is disabled${d}. Do you want to ${b}enable${u} it? (y/N)"
            generic_interactive enable "$hook" " " " "
        fi
    done

    # searching for orphaned hooks in ./.git/hooks
    for hook in "$BASE"/.git/hooks/*; do
        # early return if file is sample file
        if [[ "$hook" == *".sample" ]]; then
            continue
        fi

        acutal_hook="$(find "$BASE/$hook_dir" -name "$(basename $hook).*")"
        
        if [ -z $acutal_hook ] || [ ! -f $acutal_hook ]; then
            echo -e "\n\t${r}$(basename $hook) hook is orphaned.$u Do you want to ${b}delete$u it? (y/N)${d}"
            generic_interactive helper_disable "$(basename $hook)" "foo" "${r}deleted${d}"
        fi
    done
    echo
}

function list { # argumentless function
    echo -e "\n${b}[INFO]${u} listing all hooks ${b}(${g}enabled${d}/${y}disabled${d}/${r}orphaned${d})${u}"
    # looping over hooks in ./githooks/
    for hook_absolute_path in "$BASE/$hook_dir/"*; do
        
        hook="$(basename $hook_absolute_path)"
        hook_without_extension="$(echo "$hook" | cut -d '.' -f1)"
        if [ -f "$BASE/.git/hooks/$hook_without_extension" ]; then
            cc="$g"
        else
            cc="$y"
        fi
        echo -e "\t${b}${cc}$hook_without_extension${d}${u}"
    done

    # searching for orphaned hooks in ./.git/hooks
    for file in "$BASE"/.git/hooks/*; do
        # early return if file is sample file
        if [[ $file == *".sample" ]]; then
            continue
        fi

        # TODO: remove ${file##*/} with "basename" command for readability
        path_of_linked_script_by_hook="$(find "$BASE"/$hook_dir -name "$(basename $file).*")"
        if [ -z "$path_of_linked_script_by_hook" ] || [ ! -f "$path_of_linked_script_by_hook" ]; then
            echo -e "\t${r}$(basename $file)${d}"
        fi
    done
}

# short-hand commands
function d {
    disable $@
}
function e {
    enable $@
}
function i {
    interactive
}
function l {
    list
}

# log every invocation in a log (test runs and actual hooks
# are not included. Those are sourcing .githooker/do with is do
echo "[$(date)] $@" >> "$BASE/githooker.log" # todo change to .githooker

command=$1; shift
$command $@
