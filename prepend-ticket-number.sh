#!/bin/bash

# This pre-commit hook adds the Jira ticket number to the commit
# message. This hook assumes the branch name will follow the format
# of
# [some prefix like feat]/[Jira ticket number]-[description of the branch (optional)]
# e.g. feat/AGRO-766-apollo-schemas
#
# it will prepend a string like 'feat(AGRO-766): ' to the commit message
#
# Usage:
# copy this file locally and save it to your repo as .git/hooks/prepare-commit-msg and set the exec bit on it
#
# You can also use this as a global hook (will run for all your git repos). It might make your life harder as it will
# apply the branch naming convention to every repo you interact with locally. Best to just use it on a case by case.

COMMIT_MSG_FILE=$1

branch=`git branch --show-current`
if [[ $branch = 'master' ]]; then
    # if you have this in your global hooks you may actually want to commit to master (not all repos follow this convention),
    # so skip the prepare if you are on the master branch; the remote repo may still reject your commit though
    echo 'prepare-commit-msg: master branch, ignoring'
    exit 0
elif [[ $branch = '' ]]; then
    # rebasing, skip
    echo 'prepare-commit-msg: no branch, rebasing?'
    exit 0
elif [[ $branch == "HEAD" ]]; then
    echo 'prepare-commit-msg: non feature branch, ignoring'
    exit 0
fi

regex="^(feat|hotfix|bug)\/([A-Z]{2,5}-[0-9]{3,9}).*$"
original=`cat $1` # grab original message

# echo "$branch ${branch} regex ${regex} original ${original}"
if [[ "$branch" =~ $regex ]]; then
    type="${BASH_REMATCH[1]}"
    ticket="${BASH_REMATCH[2]}"
    #echo "type  ${type}, ticket: ${ticket}, original commit message: ${original}"
    # next line will fail if there is a % in the commit message, change that to 'percent'
    printf "$type($ticket): $original" > "$COMMIT_MSG_FILE"
else
    echo "Error: Branch name ($branch) does not match pattern: $regex" >&2
    exit 1
fi