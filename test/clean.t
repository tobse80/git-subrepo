#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

test-exists \
  "$OWNER/foo/.git/refs/subrepo/bar/commit" \
  "$OWNER/foo/.git/refs/subrepo/bar/fetch"

(
  cd $OWNER/foo
  add-new-files bar/file
  git subrepo --quiet branch bar
) || die

test-exists \
  "$OWNER/foo/.git/refs/heads/subrepo/bar" \
  "$OWNER/foo/.git/refs/subrepo/bar/branch" \
  "$OWNER/foo/.git/refs/original/refs/heads/subrepo/bar"

(
  cd $OWNER/foo
  git subrepo --quiet push bar
) || die

test-exists \
  "$OWNER/foo/.git/refs/subrepo/bar/push"


is "$(
  cd $OWNER/foo
  git subrepo clean bar
)" \
  "Removed branch 'subrepo/bar'." \
  "subrepo clean command output is correct"

test-exists \
  "!$OWNER/foo/.git/refs/heads/subrepo/bar" \
  "$OWNER/foo/.git/refs/subrepo/bar/branch" \
  "$OWNER/foo/.git/refs/subrepo/bar/commit" \
  "$OWNER/foo/.git/refs/subrepo/bar/fetch" \
  "$OWNER/foo/.git/refs/subrepo/bar/push" \
  "$OWNER/foo/.git/refs/original/refs/heads/subrepo/bar"

is "$(
  cd $OWNER/foo
  git subrepo clean --force bar
)" \
  "" \
  "subrepo clean --force command has no output"

test-exists \
  "!$OWNER/foo/.git/refs/heads/subrepo/bar" \
  "!$OWNER/foo/.git/refs/subrepo/bar/branch" \
  "!$OWNER/foo/.git/refs/subrepo/bar/commit" \
  "!$OWNER/foo/.git/refs/subrepo/bar/fetch" \
  "!$OWNER/foo/.git/refs/subrepo/bar/push" \
  "!$OWNER/foo/.git/refs/original/refs/heads/subrepo/bar"

done_testing

teardown
