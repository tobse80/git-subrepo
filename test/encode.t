#!/usr/bin/env bash

set -e

source test/setup

use Test::More


test_round() {
  clone-foo-and-bar
    
  clone_output="$(
    cd $OWNER/foo
    git subrepo clone ../../../$UPSTREAM/bar $1
  )"	   

  # Check output is correct:
  is "$clone_output" \
    "Subrepo '../../../tmp/upstream/bar' (master) cloned into '$1'." \
    'subrepo clone command output is correct'    
}

test_round .strange
test_round str%ange

done_testing

teardown
