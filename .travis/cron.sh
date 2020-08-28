#!/bin/bash

set -x

dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd $dir/..
./httpobs/scripts/httpobs-regen-hsts-preload

if [ $? -eq 1 ]; then
  set -e

  # Deal with detached head state that Travis puts us in
  git checkout master

  # Change our Git username and email to not be Travis user
  git config --global user.name "Alexandre Flament"
  git config --global user.email "alex@al-f.net"

  # Create a commit and tag with the date attached
  datetime=`date "+%Y-%-m-%-d"`
  version=`date "+%Y.%-m.%-d"`
  git add httpobs/
  git commit -m "Automatic update of the HSTS preload list on $datetime"
  git tag -a "$version" -m "$version"

  # Use our GitHub token to make the commit
  git remote rm origin
  git remote add origin https://dalf:${GITHUB_TOKEN}@github.com/dalf/http-observatory > /dev/null 2>&1
  git push origin master --quiet --tags
fi
