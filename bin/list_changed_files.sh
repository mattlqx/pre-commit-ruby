#!/bin/bash
set -e

# A thin wrapper around `git diff` that gets it right, every time.
#
# Use this script when you need an accurate diff of changes
# between your branch/commit and master on CI.
#
# Usage:
#   script/ci/list_changed_files
#   script/ci/list_changed_files --diff-filter=AM # pass any supported git-diff options
#   script/ci/list_changed_files --diff-filter=A -- components/manage # filter by filenames (separated from arguments by --)

# Having an up-to-date copy of master is crucial for an accurate diff.
# This usually happens in a Buildkite hook. If this hasn't happened,
# we'll run it now before continuing.
MAINMASTER=$(git branch -l master main | sed -r 's/^[* ] //' | head -n 1)
if [[ -z "$FRESH_GIT_MASTER_CHECKOUT" ]]; then
  git fetch --quiet origin "${MAINMASTER}"
fi


# Using `git merge-base` ensures that we're always comparing against the correct branch point. For example, given the commits:
#
# A---B---C---D---W---X---Y---Z # origin/master
#             \---E---F         # our feature branch
#
# ... `git merge-base origin/master HEAD` would return commit `D`.
git diff --name-only "$(git merge-base origin/"${MAINMASTER}" HEAD~)"...HEAD "$*"