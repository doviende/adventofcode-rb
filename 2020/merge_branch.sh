#!/bin/sh

if [[ `git status --porcelain` ]]; then
    echo "changes are present, aborting merge"
    exit 1
fi

branch=$(git branch --show-current)
git rebase master
git checkout master
git merge --no-ff --no-edit ${branch}

