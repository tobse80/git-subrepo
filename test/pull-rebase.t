#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

# Verify existence of .gitrepo file
gitrepo=$OWNER/foo/bar/.gitrepo
{
  test-exists \
    "$gitrepo"
}

# [foo] Create topic branch after subrepo was cloned
{
  (
    cd $OWNER/foo
    git branch topic
  ) &> /dev/null || die
}

# [bar] Commit some work
{
  (
    cd $OWNER/bar
    add-new-files Bar1
    git push
  ) &> /dev/null || die
}

# [foo] Pull changes into topic branch; check subrepo command output
{
  (
    cd $OWNER/foo
    git checkout topic
  ) &> /dev/null || die

  is "$(
    cd $OWNER/foo
    git subrepo pull bar
  )" \
    "Subrepo 'bar' pulled from '../../../tmp/upstream/bar' (master)." \
    'subrepo pull command output is correct'
}

# Test foo/bar/.gitrepo file contents
{
  foo_pull_commit="$(cd $OWNER/foo; git rev-parse HEAD^)"
  bar_head_commit="$(cd $OWNER/bar; git rev-parse HEAD)"
  test-gitrepo-comment-block
  test-gitrepo-field "remote" "../../../$UPSTREAM/bar"
  test-gitrepo-field "branch" "master"
  test-gitrepo-field "commit" "$bar_head_commit"
  test-gitrepo-field "parent" "$foo_pull_commit"
  test-gitrepo-field "cmdver" "`git subrepo --version`"
}

# [bar] Commit some more work
{
  (
    cd $OWNER/bar
    add-new-files Bar2
    git push
  ) &> /dev/null || die
}

# [foo] Also commit some work on master
{
  (
    cd $OWNER/foo
    git checkout master
    add-new-files Foo3
  ) &> /dev/null || die
}

# Debug output
(
  echo '>>> [foo] before rebase'
  cd $OWNER/foo
  git log topic master --oneline --decorate --graph
)

# [foo] *Rebase* topic branch and pull changes; check subrepo command output
{
  (
    cd $OWNER/foo
    git checkout topic
    git rebase master
  ) &> /dev/null || die

  is "$(
    cd $OWNER/foo
    git subrepo pull bar
  )" \
    "Subrepo 'bar' pulled from '../../../tmp/upstream/bar' (master)." \
    'subrepo pull command output is correct'
}

# Debug output
(
  echo '>>> [foo] after rebase'
  cd $OWNER/foo
  git log topic master --oneline --decorate --graph
)
(
  echo '>>> [bar]'
  cd $OWNER/bar
  git log master --oneline --decorate --graph
)

# Test foo/bar/.gitrepo file contents
{
  foo_pull_commit="$(cd $OWNER/foo; git rev-parse HEAD^)"
  bar_head_commit="$(cd $OWNER/bar; git rev-parse HEAD)"
  test-gitrepo-comment-block
  test-gitrepo-field "remote" "../../../$UPSTREAM/bar"
  test-gitrepo-field "branch" "master"
  test-gitrepo-field "commit" "$bar_head_commit"
  test-gitrepo-field "parent" "$foo_pull_commit"
  test-gitrepo-field "cmdver" "`git subrepo --version`"
}

done_testing

teardown
