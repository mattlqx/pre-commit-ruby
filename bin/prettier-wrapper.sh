#!/bin/bash
set -e

trap 'print_error' ERR

if [[ $(git log -1 --pretty=%B) == Revert* ]]
then
  echo "Not running prettier because this looks like a revert commit, and we would"
  echo "prefer to let reverts into production without subjecting them to formatting, "
  echo "because a commit that fixed some formatting could also have introduced a bug"
  exit 0
fi

diff=$(bin/list_changed_files.sh --diff-filter=ACMRXB | grep "components/manage/" | sed 's:^components/manage/::' | xargs)

if [ -z "$diff" ]
then
  echo "No matching files - skipping step."
else
  yarn --cwd "components/manage" prettier --check "$diff"
fi