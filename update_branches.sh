#!/bin/sh
#
# Copyright 2013 Eamon Banta
#
# update_branches - A script to update a pre-defined list of mercurial
#                        repositories to new branch.
#
# Usage: update_branches BRANCH_NUMBER ROOT_DIR [FILENAME] [LOG]

##### Constants

BRANCH_NUMBER="$1"
ROOT_DIR="$2"
FILENAME="$3"
LOG="$4"

if [ "$FILENAME" ]; then
    BRANCHES_FILE=$ROOT_DIR/$FILENAME
else
    BRANCHES_FILE=$ROOT_DIR/branches.config
fi

if [ ! "$LOG" ]; then
    LOG=/dev/null
fi

##### Check Usage

if [ ! "$BRANCH_NUMBER" ] || [ ! -e "$BRANCHES_FILE" ]; then
    echo "Usage: update_branches.sh BRANCH_NUMBER REPOSITORIES_ROOT [REPOSITORIES_FILE] [LOG]"
    exit
fi

##### Main

cd "$ROOT_DIR"

if [ $(pwd) != "$ROOT_DIR" ]; then
    echo "Can't change to ${ROOT_DIR}."
    exit
fi

while read branch; do
    if [ -d "$branch" ]; then
        cd "$branch"

        old_branch=$(hg branch)
        new_branch="${branch}-${BRANCH_NUMBER}"

        if [ "$old_branch" = "$new_branch" ]; then
            echo "Not updating ${old_branch}"
            cd "${ROOT_DIR}"
            continue
        fi

        echo "Updating ${old_branch} => ${new_branch}"

        hg pull > "$LOG"
        hg up "$new_branch" > "$LOG"
        python setup.py develop > "$LOG"

        cd "$ROOT_DIR"
    fi
done < "$BRANCHES_FILE"

exit
