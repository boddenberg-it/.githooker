#!/bin/bash

# unlink orphaned symlinks in .git/hooks
for file in .git/hooks/*; do
    [ grep -v ".sample" $file ] || break
    if [ "$(ls ./githooks | grep -c "$file")" -lt 1 ]; then
        unlink "$file" || rm "$file"
    fi
done

# create/fix missing/broken sym-links
for file in ./git-hooks/*; do
    file_without_extension="$(cut -d '.' -f1 "$file")"

    if [ -f ".git/hooks/$file_without_extension" ]; then
        if [ "$(ls -l ".git/hooks/$file_without_extension" | tail -n +2 | grep -oE '[^ ]+$')" = "$file" ]; then
            continue # everything's fine
        else
            # there is a file, but it's not a sym-link or it points to wrong file - fixing it.
            rm ".git/hooks/$file_without_extension"
            ln -s ".git/hooks/$file_without_extension" "./git-hooks/$file"
        fi
    else
        # sym-link isn't in place create it
        ln -s ".git/hooks/$file_without_extension" "./git-hooks/$file" 
    fi
done
